
% Example map: https://goo.gl/maps/M2Nhq3hJnZPPF9Z66; https://goo.gl/maps/RbgEk9N7MUUfA1xg6
% Extract GPS points and write as JSON file from: https://mapstogpx.com/

%% Reading JSON file and writing to as struct
fileName = 'SC_drive.json'; % filename in JSON extension
str = fileread(fileName); % dedicated for reading files as text
data = jsondecode(str); % Using the jsondecode function to parse JSON from string

%% Extracting GPS data from struct
lat = [data.start.lat];
lng = [data.start.lng];

for i=1:1:length(data.points)
    temp_lat = data.points{i, 1}.lat;
    temp_lng = data.points{i, 1}.lng;

    lat = [lat, temp_lat];
    lng = [lng, temp_lng];
end


lat = [lat, data.end.lat];
lng = [lng, data.end.lng];

%% Ploting GPS points
figure(1)
geoplot(lat, lng, "ro-","LineWidth", 2, "MarkerSize",2)
geobasemap streets

%% Extract Map Roads using GPS data

zoomLevel = 16;
center1 = mean(lat);
center2 = mean(lng);
player = geoplayer(center1 ,center2 ,zoomLevel);
plotRoute(player, lat, lng);

mapStruct = getMapROI(lat,lng);
url = mapStruct.osmUrl;
filename = "drive_map_SC.osm";
websave(filename,url,weboptions(ContentType="xml"));

%% Extract road properties and geographic reference coordinates to use to identify ego roads by using the roadprops function
% [roadData,geoReference] = roadprops("OpenStreetMap",filename);
% cropWindow = [-30 -30 200 200];
% helperPlotRoads(roadData,cropWindow);

%% Convert Route to Cartesian Coordinates
alt=10;
origin = [lat(1), lng(1), alt];
[xEast,yNorth,zUp] = latlon2local(lat,lng,alt,origin);
waypoints = [xEast; yNorth; zUp]';

figure(4);
plot(xEast, yNorth)
axis('equal'); % set 1:1 aspect ratio to see real-world shape

%% Quick plot of road
scenario = drivingScenario;
roadCenters = waypoints;
roadWidth = 3;
lm = [laneMarking('Solid')
      laneMarking('Dashed','Length',2,'Space',4)
      laneMarking('Solid')];
l = lanespec(2,'Marking',lm);
road(scenario,roadCenters,'Lanes',l);
plot(scenario)
view(0, 90);

%% Add smoothning factor to clear abruptness
window = round(size(waypoints,1)*0.2);
waypoints2 = smoothdata(waypoints,"rloess",window);
scenario2 = drivingScenario;
roadCenters2 = waypoints2;
roadWidth = 3;
lm = [laneMarking('Solid')
      laneMarking('Dashed','Length',2,'Space',4)
      laneMarking('Solid')];
l = lanespec(2,'Marking',lm);
TestRoad= road(scenario2,roadCenters2,'Lanes',l);
plot(scenario2)
view(0, 90);

%%
export(scenario2,"OpenDRIVE","SantaClara.xodr")