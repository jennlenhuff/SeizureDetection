function PlotResults(Detections)
stage0_hits = 0;
stage1_hits = 0;
stage2_hits = 0;
stage3_hits = 0;
stage4_hits = 0;
stage5_hits = 0;

stage0_misses = 0;
stage1_misses = 0;
stage2_misses = 0;
stage3_misses = 0;
stage4_misses = 0;
stage5_misses = 0;

files = fieldnames(Detections);

for i = 1:numel(files)
    current_file = Detections.(files{i});
    stage0_hits = current_file.Stage0.hits + stage0_hits;
    stage1_hits = current_file.Stage1.hits + stage1_hits;
    stage2_hits = current_file.Stage2.hits + stage2_hits;
    stage3_hits = current_file.Stage3.hits + stage3_hits;
    stage4_hits = current_file.Stage4.hits + stage4_hits;
    stage5_hits = current_file.Stage5.hits + stage5_hits;

    stage0_misses = current_file.Stage0.misses + stage0_misses;
    stage1_misses = current_file.Stage1.misses + stage1_misses;
    stage2_misses = current_file.Stage2.misses + stage2_misses;
    stage3_misses = current_file.Stage3.misses + stage3_misses;
    stage4_misses = current_file.Stage4.misses + stage4_misses;
    stage5_misses = current_file.Stage5.misses + stage5_misses;
end

bars = [stage0_hits / (stage0_hits+stage0_misses), stage0_misses / (stage0_hits+stage0_misses);
    stage1_hits / (stage1_hits+stage1_misses), stage1_misses / (stage1_hits+stage1_misses);
    stage2_hits / (stage2_hits+stage2_misses), stage2_misses / (stage2_hits+stage2_misses);
    stage3_hits / (stage3_hits+stage3_misses), stage3_misses / (stage3_hits+stage3_misses);
    stage4_hits / (stage4_hits+stage4_misses), stage4_misses / (stage4_hits+stage4_misses);
    stage5_hits / (stage5_hits+stage5_misses), stage5_misses / (stage5_hits+stage5_misses)];
figure()
bar(bars,'stacked')
set(gca,'xticklabel',{'0','1','2','3','4','5'});
xlabel('Seizure Stage'); ylabel('Fraction of hits or misses');
legend('Hits','Misses');