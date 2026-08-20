clear; clc;

%% =============================
% INPUTS
%% =============================
speeds_mph = [35 45 55];

speeds_fps = speeds_mph * 1.467;

PRT = 2.4;                    % perception-reaction time (sec)
friction = [0.80 0.70 0.60];  % BEST -> WORST
g = 32.2;                     % gravity (ft/s^2)

% Pedestrian exposure time (sec)
ped_exposure_time = 0.7;



% Available distance during pedestrian exposure
available_dist = speeds_fps .* ped_exposure_time;

%% =============================
% CALCULATIONS
%% =============================
total_dist = zeros(length(speeds_mph), length(friction));

for i = 1:length(speeds_fps)

    v = speeds_fps(i);
    prt_dist = v * PRT;

    for j = 1:length(friction)

        f = friction(j);

        braking_dist = (v^2) / (2 * g * f);

        total_dist(i,j) = prt_dist + braking_dist;

    end
end

%% =============================
% REVERSE ORDER FOR PLOTTING
% Highest friction appears at top
%% =============================
plot_friction = friction(end:-1:1);
plot_dist = total_dist(:,end:-1:1);

%% =============================
% PLOT
%% =============================
figure;
hold on;

b = barh(speeds_mph, plot_dist, 'grouped');

%% =============================
% BAR COLORS
% Green (best) -> Yellow -> Red (worst)
%% =============================
nFric = length(plot_friction);

fricColors = [ ...
    linspace(1.00,0.15,nFric)' ...
    linspace(0.15,0.75,nFric)' ...
    zeros(nFric,1)];

for j = 1:nFric
    b(j).FaceColor = fricColors(j,:);
end

%% =============================
% AXES
%% =============================
set(gca,'YTick',speeds_mph);

if length(speeds_mph) > 1
    speedSpacing = min(diff(sort(speeds_mph)));
else
    speedSpacing = 10;
end

ylim([ ...
    min(speeds_mph)-0.6*speedSpacing ...
    max(speeds_mph)+0.6*speedSpacing]);

xlabel('Distance (ft)', ...
    'FontSize',12,'FontWeight','bold');

ylabel('Vehicle Speed (mph)', ...
    'FontSize',12,'FontWeight','bold');

title(sprintf('Total Braking Distance'), ...
    'FontSize',13,'FontWeight','bold');

grid on;
box on;

%% =============================
% FINAL FORMATTING
%% =============================
set(gca,'FontSize',11);

set(gcf,'Position',[100 100 1100 650]);

xlim([0 max(total_dist(:))*1.25]);

%% =============================
% AVAILABLE DISTANCE LINES
% Full-height lines
%% =============================
lineColors = lines(length(speeds_mph));

yl = ylim;

line_handles = gobjects(length(speeds_mph),1);

for i = 1:length(speeds_mph)

    line_handles(i) = line( ...
        [available_dist(i) available_dist(i)], ...
        yl, ...
        'Color',lineColors(i,:), ...
        'LineStyle','--', ...
        'LineWidth',2);

end


%% =============================
% LEGEND (AUTO)
%% =============================
friction_labels = arrayfun( ...
    @(f) sprintf('f = %.2f',f), ...
    plot_friction, ...
    'UniformOutput',false);

distance_labels = arrayfun( ...
    @(s) sprintf('Available Distance @ %d mph',s), ...
    speeds_mph, ...
    'UniformOutput',false);

legend([b(:); line_handles], ...
       [friction_labels distance_labels], ...
       'Location','eastoutside');

hold off;

%% =============================
% EXPORT
%% =============================
saveas(gcf,'StoppingDistance_Parametric_Final.png');
