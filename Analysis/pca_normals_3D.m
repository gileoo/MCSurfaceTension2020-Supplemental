npoints = 1000;
r = 1.;

theta = rand(npoints, 1)*180;
phi = rand(npoints, 1)*360;

x = r.*sin(theta).*cos(phi);
y = r.*sin(theta).*sin(phi);
z = r.*cos(theta);

ptCloud = pointCloud([x,y,z]);
normals = pcnormals(ptCloud, 4);
u = normals(:, 1);
v = normals(:, 2);
w = normals(:, 3);

% Flip the normals to point towards the sensor location.
sensorCenter = [0, 0, 0]; 
for k = 1 : numel(x)
   p1 = sensorCenter - [x(k),y(k),z(k)];
   p2 = [u(k),v(k),w(k)];
   % Flip the normal vector if it is pointing towards the sensor.
   angle = atan2(norm(cross(p1,p2)), p1*p2');
   if angle < pi/2 && angle > -pi/2
       u(k) = -u(k);
       v(k) = -v(k);
       w(k) = -w(k);
   end
end

% Plot the adjusted normals.
figure
pcshow(ptCloud)
title('Adjusted Normals of Point Cloud')
hold on
quiver3(x, y, z, u, v, w);
hold off