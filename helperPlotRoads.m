function helperPlotRoads(roadParams, cropWindow, NameValueArgs)
% This is a helper function for example purposes and may be removed or
% modified in the future.

% Copyright 2022 The MathWorks, Inc.

arguments
    roadParams
    cropWindow
    NameValueArgs.DataTips=false
end

if isa(roadParams,'roadrunnerHDMap')
    figure
    hAxes1 = subplot(1,2,1);
    title("RoadRunner HD Map");
    plot(roadParams,'Parent',hAxes1)
    rectangle("Position",[cropWindow(1), cropWindow(2), cropWindow(3), cropWindow(4)],"EdgeColor", "r","LineWidth",2)
    hAxes2 = subplot(1,2,2);
    title("Zoomed View");
    plot(roadParams,'Parent',hAxes2)
    xlim([cropWindow(1),cropWindow(3)+cropWindow(1)])
    ylim([cropWindow(2),cropWindow(4)+cropWindow(2)])
    rectangle("Position",[cropWindow(1), cropWindow(2), cropWindow(3), cropWindow(4)],"EdgeColor", "r","LineWidth",2)
    legend("Lane Boundaries","Lane Centers")
else
    JuncIDs = find(roadParams.JunctionID~=0);
    roadSegIDs = find(roadParams.JunctionID==0);
    scenario = drivingScenario;
    for i = 1:size(roadSegIDs,1)
        roadID = roadSegIDs(i);
        roadCenters = roadParams.RoadCenters{roadID};
        lanes = roadParams.Lanes(roadID);
        if iscell(lanes)
            lanes = lanes{1};
        end
        road(scenario,roadCenters,'Lanes',lanes);
    end
    JunctionNums = unique(roadParams.JunctionID(JuncIDs));
    for i = 1:size(JunctionNums,1)
        juncID = JunctionNums(i);
        roadSegIDs = find(roadParams.JunctionID==juncID);
        rg = driving.scenario.RoadGroup;
        for j = 1:size(roadSegIDs,1)
            roadID = roadSegIDs(j);
            roadCenters = roadParams.RoadCenters{roadID};
            width = mean(roadParams.RoadWidth{roadID});
            road(rg,roadCenters,width);
        end
        roadGroup(scenario,rg);
    end
    figure
    hAxes1 = subplot(1,2,1);
    title("Extracted Roads");
    plot(scenario,'Parent',hAxes1);

    if NameValueArgs.DataTips
        hold on;
        for i = 1:size(roadSegIDs,1)
            idx = roadSegIDs(i);
            roadID = roadParams.RoadID(idx);
            centers = roadParams.RoadCenters{idx};
            centers = centers(1:50:end,:);
            p = plot3(centers(:,1), centers(:,2), centers(:,3)+0.5,'o','MarkerEdgeColor','black','MarkerFaceColor','black');
            row = dataTipTextRow("RoadID",roadID*ones(size(centers,1),1));
            p.DataTipTemplate.DataTipRows(end+1) = row;
            datatip(p,"DataIndex",floor(size(centers,1)/2));
        end
        hold off;
    end

    rectangle("Position",[cropWindow(1), cropWindow(2), cropWindow(3), cropWindow(4)],"EdgeColor", "r","LineWidth",2)
    hAxes2 = subplot(1,2,2);
    title("Zoomed View")
    plot(scenario,'Parent',hAxes2)
    xlim([cropWindow(1),cropWindow(3)+cropWindow(1)])
    ylim([cropWindow(2),cropWindow(4)+cropWindow(2)])
    rectangle("Position",[cropWindow(1), cropWindow(2), cropWindow(3), cropWindow(4)],"EdgeColor", "r","LineWidth",2)
end