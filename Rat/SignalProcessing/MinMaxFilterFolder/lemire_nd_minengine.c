/*************************************************************************
 * MATLAB MEX ROUTINE LEMIRE_ND_MINENGINE.C
 * [minval idxmax] = LEMIRE_ND_MINENGINE(a, idx, window, shapeflag)
 *
 * PURPOSE: multiple 1D min running/filtering
 * Similar to LEMIRE_ENGINE but working on the second dimension, while
 * looping along the first and third dimensions. This MEX is used for
 * the engine for multidimensional min/max filtering
 *
 * INPUTS
 *  A: 3D arrays, logical and all numeric classes are supported
 *  idx: 3D arrays, double, user input, must have the same number
 *       of elements as A
 *  window: scalar, size of the sliding window, must be >= 1
 *  shapeflag: double scalar: 1, 2, 3 resp. for valid, same and full shape
 * 
 * OUTPUTS
 *  For "valid" shape (without shapeflag passing)
 *  minval: running min, vectors of dimension (length(A)-window+1), i.e.,
 *      minval(:,1,:) is min(A(:,1:win,:))
 *      minval(:,2,:) is min(A(:,2:win+1,:))
 *      ...
 *      minval(:,end,:) is min(A(:,end-window+1:end,:))
 *  For "Same" shape output has the same dimension as A
 *  For "Full" shape (with shapeflag)
 *  output MINVAL has dimension (length(A)+window-1), correspond to all 
 *  positions of sliding window that is intersect with A
 *  
 *  minidx: 3D arrays, subjected the same assignment as minval
 *          The main purpose is to keep track of indexing during
 *          runing filter
 *
 * Note: if the data is complex, the imaginary part is ignored.
 *       window is limited to 2147483646 (2^31-2)
 *
 * Algorithm: Lemire's "STREAMING MAXIMUM-MINIMUM FILTER USING NO MORE THAN
 * THREE COMPARISONS PER ELEMENT" Nordic Journal of Computing, Volume 13,
 * Number 4, pages 328-339, 2006.
 *
 * Compilation:
 *  >> mex -O -R2018a lemire_nd_minengine.c 
 *  >> mex -O -v lemire_nd_minengine.c 
 * % add -largeArrayDims on 64-bit computer
 *  >> mex -largeArrayDims -O -v lemire_nd_minengine.c
 *
 * see aldo: lemire_nd_maxengine.c, minmaxfilter
 *           median filter, Kramer & Bruckner filter
 *
 * Author: Bruno Luong <brunoluong@yahoo.com>
 * Contributor: Vaclav Potesil
 * History
 *  Original: 20/Sep/2009
 *  Last update: 22/Sep/2009, input shapeflag always required
 *                            same shape scan
 ************************************************************************/

#include "mex.h"
#include "matrix.h"

/* Uncomment this on older Matlab version where size_t has not been
 * defined */
/*
 * #define mwSize int
 * #define size_t int
 */

/* Define correct type depending on platform 
  You might have to modify here depending on your compiler */
#if defined(_MSC_VER) || defined(__BORLANDC__)
typedef __int64 int64;
typedef __int32 int32;
typedef __int16 int16;
typedef __int8 int08;
typedef unsigned __int64 uint64;
typedef unsigned __int32 uint32;
typedef unsigned __int16 uint16;
typedef unsigned __int8 uint08;
#else /* LINUX + LCC, CAUTION: not tested by the author */
typedef long long int int64;
typedef long int int32;
typedef short int16;
typedef char int08;
typedef unsigned long long int uint64;
typedef unsigned long int uint32;
typedef unsigned short uint16;
typedef unsigned char uint08;
#endif

/* Maximum (32-bit) integer */
#define MAXINT 0x7fffffff
            
/* This is the engine macro, used for different data type */
/* Note: j -> third dimension
 *       k -> first dimension
 *       i -> second (working) dimension */
#define SCAN(a, minval, type) { \
for (j=0; j<q; j++) { \
    a = (type*)adata + j*stepA; \
    idx = idxdata + j*stepA; \
    minval = (type*)valdata + j*stepMinMax; \
    minidx = minidxdata + j*stepMinMax; \
    for (k=0; k<p; k++) { \
        nWedge = 0; \
        Wedgefirst = 0; \
        Wedgelast = -1; \
        left = -(int)(window); \
        pleft = 0; \
        for (i=1; i<n; i++) { \
            left++; \
            if (left >= lstart) { \
                linidx = p*(nWedge? Wedge[Wedgefirst] : i-1); \
                minidx[pleft] = idx[linidx]; \
                minval[pleft] = a[linidx]; \
                pleft += p; \
            } \
            if (a[p*i] < a[p*(i-1)]) { \
                while (nWedge) { \
                    if (a[p*i] >= a[p*Wedge[Wedgelast]]) { \
                        if (left == Wedge[Wedgefirst]) { \
                            nWedge--; \
                            if ((++Wedgefirst) == size) Wedgefirst = 0; \
                        } \
                        break; \
                    } \
                    nWedge--; \
                    if ((--Wedgelast) < 0) Wedgelast += size; \
                } \
            } \
            else { \
                nWedge++; \
                if ((++Wedgelast) == size) Wedgelast = 0; \
                Wedge[Wedgelast] = i-1; \
                if (left == Wedge[Wedgefirst]) { \
                    nWedge--; \
                    if ((++Wedgefirst) == size) Wedgefirst = 0; \
                } \
            } \
        } \
        for (i=n; i<=imax; i++) { \
            left++; \
            linidx = p*(nWedge? Wedge[Wedgefirst] : n-1); \
            minidx[pleft] = idx[linidx]; \
            minval[pleft] = a[linidx]; \
            pleft += p; \
            nWedge++; \
            if ((++Wedgelast) == size) Wedgelast = 0; \
            Wedge[Wedgelast] = n-1; \
            if (left == Wedge[Wedgefirst]) { \
                nWedge--; \
                if ((++Wedgefirst) == size) Wedgefirst = 0; \
            } \
        } \
        a++; idx++; \
        minval++; minidx++; \
    } \
} }
/* end SCAN */

#define VALID_SHAPE 1
#define SAME_SHAPE 2
#define FULL_SHAPE 3
/* Define the name for Input/Output ARGUMENTS */
#define A prhs[0]
#define IDX prhs[1]
#define WINDOW prhs[2]
#define SHAPE prhs[3]
/* Out */
#define MINVAL plhs[0]
#define MINIDX plhs[1]

/* Gateway of LEMIRE_ND_MINENGINE */
void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[]) {
    
    mxClassID ClassID;
    
    /* pointer to the index array */
    double *idx, *minidx;
    /* Data pointers, which one are used depends on the class of A */
    double *adouble, *valdouble;
    float *asingle, *valsingle;
    int64 *aint64, *valint64;
    int32 *aint32, *valint32;
    int16 *aint16, *valint16;
    int08 *aint08, *valint08;
    uint64 *auint64, *valuint64;
    uint32 *auint32, *valuint32;
    uint16 *auint16, *valuint16;
    uint08 *auint08, *valuint08;

    mwSize i, pleft, n, window;
    mwSize imax, margin, linidx;
    int left, lstart, size;
    mwSize *Wedge; /* wedge */
    int nWedge; /* wedge number of elements (0 is empty wedge) */
    int Wedgefirst, Wedgelast; /* Indices of two ends of the wedge */
    int shape;
    
    mwSize p, q, j, k;
    mwIndex stepA, stepMinMax;
    const mwSize* dimA;
    mwSize dimOut[3];
    
    void *adata, *valdata;
    double *idxdata, *minidxdata;
    
    /* Check number of arguments */
    if (nrhs!=4)
        mexErrMsgTxt("LEMIRE_ND_MINENGINE: four arguments are required.");
    
     /* Get the shape */
    shape = (int)mxGetScalar(SHAPE);
    
    /* Get class of input matrix A */
    ClassID = mxGetClassID(A);
    
    if (mxGetClassID(IDX) != mxDOUBLE_CLASS)
        mexErrMsgTxt("LEMIRE_ND_MINENGINE: idx must be double.");
    
    /* Do not support on sparse */
    if (mxIsSparse(A))
        mexErrMsgTxt("LEMIRE_ND_MINENGINE: First input A must be full.");       
    
    /* Get the number of elements of A */
    /* Get the size, MUST BE two or three, no check */
    dimA = mxGetDimensions(A);
    p = dimA[0];
    n = dimA[1];
    if (mxGetNumberOfDimensions(A)<3)
        q = 1; /* third dimension is singleton */
    else
        q = dimA[2];
   
    /* Window input must be double */
    if (mxGetClassID(WINDOW)!=mxDOUBLE_CLASS)
        mexErrMsgTxt("LEMIRE_ND_MINENGINE: Second input WINDOW must be double.");
    
    /* Get the window size, cast it in mwSize */
    window = (mwSize)(mxGetScalar(WINDOW));
    margin = window-1;
    
    if (window<1) /* Check if it's valid */
        mexErrMsgTxt("LEMIRE_ND_MINENGINE: windows must be 1 or greater.");   
    if (window>n || window>MAXINT)
        mexErrMsgTxt("LEMIRE_ND_MINENGINE: windows larger than data length.");
    
    /* Allocate wedges buffers for L and U, each is size (window+1) */
    size = (int)(window+1);
    Wedge = mxMalloc(size*sizeof(mwSize));
    if (Wedge==NULL) mexErrMsgTxt("LEMIRE_ND_MINENGINE: out of memory.");
    
    /* This parameters configure for three cases:
     * - full scan (minimum 1-element intersecting with window), or
     * - same scan (output has the same size as input)
     * - valid scan (full overlapping with window) */ 
    if (shape==FULL_SHAPE) {
        dimOut[1] = n+margin;
        lstart = -(int)(margin);
    } else if (shape==SAME_SHAPE) {
        dimOut[1] = n;
        lstart = -(int)(margin/2);
    } else { /* if (shape==VALID_SHAPE) */
        dimOut[1] = n-margin;
        lstart = 0;
    }
    
    /* The last index to be scanned */
    imax = (dimOut[1] + margin) + lstart;
    
    /* Create output arrays */
    dimOut[0] = p;
    dimOut[2] = q;

    MINVAL = mxCreateNumericArray(3, dimOut, ClassID, mxREAL);
    MINIDX = mxCreateNumericArray(3, dimOut, mxDOUBLE_CLASS, mxREAL); 
    /* Check if allocation is succeeded */
    if ((MINVAL==NULL) || (MINIDX==NULL))
         mexErrMsgTxt("LEMIRE_ND_MINENGINE: out of memory.");    
      
    /* Jump step of the third dimension */
    stepA = p*n; /* for A */
    stepMinMax = p*dimOut[1]; /* step for output */
    
     /* Get data pointers */
#if MX_HAS_INTERLEAVED_COMPLEX
    idxdata     = mxGetDoubles(IDX); 
    minidxdata  = mxGetDoubles(MINIDX);
    switch (ClassID) {
        case mxDOUBLE_CLASS:
             adata       = mxGetDoubles(A);
             valdata     = mxGetDoubles(MINVAL);
             SCAN(adouble, valdouble, double);
             break;
        case mxSINGLE_CLASS:
             adata       = mxGetSingles(A);
             valdata     = mxGetSingles(MINVAL);
             SCAN(asingle, valsingle, float);
             break;
        case mxINT64_CLASS:
             adata       = mxGetInt64s(A);
             valdata     = mxGetInt64s(MINVAL);
             SCAN(aint64, valint64, int64);
             break;
        case mxUINT64_CLASS:
             adata       = mxGetUint64s(A);
             valdata     = mxGetUint64s(MINVAL);
             SCAN(auint64, valuint64, uint64);
             break;
        case mxINT32_CLASS:
             adata       = mxGetInt32s(A);
             valdata     = mxGetInt32s(MINVAL);
             SCAN(aint32, valint32, int32);
             break;
        case mxUINT32_CLASS:
             adata       = mxGetUint32s(A);
             valdata     = mxGetUint32s(MINVAL);
             SCAN(auint32, valuint32, uint32);
             break;
        case mxCHAR_CLASS:
             adata       = mxGetUint16s(A);
             valdata     = mxGetUint16s(MINVAL);
             SCAN(auint16, valuint16, uint16);
             break;
        case mxINT16_CLASS:
             adata       = mxGetInt16s(A);
             valdata     = mxGetInt16s(MINVAL);
             SCAN(aint16, valint16, int16);
             break;
        case mxUINT16_CLASS:
             adata       = mxGetUint16s(A);
             valdata     = mxGetUint16s(MINVAL);
             SCAN(auint16, valuint16, uint16);
             break;
        case mxLOGICAL_CLASS:
             adata       = mxGetUint8s(A);
             valdata     = mxGetUint8s(MINVAL);
             SCAN(auint08, valuint08, uint08);
             break;
        case mxINT8_CLASS:
             adata       = mxGetInt8s(A);
             valdata     = mxGetInt8s(MINVAL);
             SCAN(aint08, valint08, int08);
             break;
        case mxUINT8_CLASS:
             adata       = mxGetUint8s(A);
             valdata     = mxGetUint8s(MINVAL);
             SCAN(auint08, valuint08, uint08);
             break;
        default:
            mexErrMsgTxt("LEMIRE_ND_MINENGINE: Class not supported.");
    } /* switch */
#else  
    idxdata     = mxGetPr(IDX); 
    minidxdata  = mxGetPr(MINIDX);       
    adata       = mxGetData(A);
    valdata     = mxGetData(MINVAL);    
        
    /* Call the engine depending on ClassID */
    switch (ClassID) {
        case mxDOUBLE_CLASS:
            SCAN(adouble, valdouble, double);
            break;
        case mxSINGLE_CLASS:
            SCAN(asingle, valsingle, float);
            break;
        case mxINT64_CLASS:
            SCAN(aint64, valint64, int64);
            break;
        case mxUINT64_CLASS:
            SCAN(auint64, valuint64, uint64);
            break;
        case mxINT32_CLASS:
            SCAN(aint32, valint32, int32);
            break;
        case mxUINT32_CLASS:
            SCAN(auint32, valuint32, uint32);
            break;
        case mxCHAR_CLASS:
            SCAN(auint16, valuint16, uint16);
            break;
        case mxINT16_CLASS:
            SCAN(aint16, valint16, int16);
            break;
        case mxUINT16_CLASS:
            SCAN(auint16, valuint16, uint16);
            break;
        case mxLOGICAL_CLASS:
            SCAN(auint08, valuint08, uint08);
            break;
        case mxINT8_CLASS:
            SCAN(aint08, valint08, int08);
            break;
        case mxUINT8_CLASS:
            SCAN(auint08, valuint08, uint08);
            break;
        default:
            mexErrMsgTxt("LEMIRE_ND_MINENGINE: Class not supported.");
    } /* switch */
#endif
    
    /* Free the buffer */
    mxFree(Wedge);
    
    return;
    
} /* Gateway LEMIRE_ND_MINENGINE */
