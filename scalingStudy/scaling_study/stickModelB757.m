% script to generate stick model for lattice & shell B757 wing

close all;
clear all;




load('C:\Users\ktrinh\MADCAT\scaling_study\gtm_stiff_wing_0_percent_fuel_data.mat');
Lambda = 22.896;
dihedral = 5.;

EIyy_nastran = 1.52e9*Iyyd(1)*144;   % 3.8604e+11   I = 253
fprintf('EIyyd root Nastran: %e\n',EIyy_nastran);
I_root = 25300;

% convert to inch
% x = xd*cosd(Lambda)*12.;
% y = xd*sind(Lambda)*12.;
% z = xd*atand(Lambda)*12.;
x = xd*cosd(Lambda);
y = xd*sind(Lambda);
z = xd*tand(dihedral);
numNodes = length(x);
numElems = numNodes-1;

figure;
hold on;
%axis equal;
grid on;
plot(x,Ixxd,'*r');


figure;
hold on;
%axis equal;
grid on;
% plot(x,Ixxd,'*r');
plot(x,Iyyd,'*b');
plot(x,Jd,'*k');

pftemp = polyfit(x, Iyyd, 4);
yfit = polyval(pftemp,x)/Iyyd(1);
plot(x,yfit,'*c');
pf1 = polyfit(x, yfit, 4);


% figure;
% hold on;
% axis equal;
% grid on;
% plot3(x,y,z,'*r');
% plot3(x,y,z,'b');

outfile = 'VoxelShell_GTM_stick.inp';
fid=fopen(outfile,'w');
fprintf(fid,'*Heading\n');
fprintf(fid,'Stick model for GTM wing with voxel substructure\n');
fprintf(fid,'*Part, name=GTM\n');
fprintf(fid,'**\n');
fprintf(fid,'*Node\n');
for i=1:numNodes
    fprintf(fid,'%d, %f, %f, %f\n',i,x(i), y(i), z(i));
    
end

for i=1:numElems
    fprintf(fid,'*ELEMENT, TYPE=B31, ELSET=Beam_%d\n',i);
    fprintf(fid,'%d, %d, %d\n',i,i,i+1);
end

hold on;
grid on;

for i=1:numElems
    fprintf(fid,'*BEAM SECTION, ELSET=Beam_%d, SECTION=CIRC, MATERIAL=MAT1\n',i);
    xVal = x(i);
    %I = I_root*polyval(pf1,xVal);
    I = (Iyyd(i)+Iyyd(i+1))/2.
    radius = I*4/pi;
    radius = nthroot(radius,4);
    fprintf('radius %f, I %f\n',radius, I);
    %disp(stiffness);
    fprintf(fid,'%f\n', radius);
    Icalc = pi*radius^4/4.;
    fprintf(fid,'%f\n', Icalc);
    %plot(xVal,stiffness,'or');
end

EI_root = I_root*1.52e9;
fprintf('EI_root is %e\n',EI_root);
fprintf('EIyyd root Nastran: %e\n',EIyy_nastran);
ratio_root_o_nastran = EI_root/EIyy_nastran;
fprintf('ratio of EIyyd root lattice/Nastran: %e\n',ratio_root_o_nastran);

fprintf(fid,'*End Part\n');
fprintf(fid,'*Assembly, name=Assembly\n');
fprintf(fid,'*Instance, name=beam-1, part=GTM\n');
fprintf(fid,'*End Instance\n');
fprintf(fid,'*Nset, nset=fixed_nodes, instance=beam-1\n');
fprintf(fid,'1\n');
fprintf(fid,'*Nset, nset=moved_nodes, instance=beam-1\n\n');
fprintf(fid,'101\n');
fprintf(fid,'**\n');
fprintf(fid,'**\n');
fprintf(fid,'**\n');
fprintf(fid,'**\n');
fprintf(fid,'**\n');
fprintf(fid,'*End Assembly\n');
fprintf(fid,'*MATERIAL, NAME=MAT1\n');
fprintf(fid,'*ELASTIC\n');
fprintf(fid,'1.52e9,0.33\n');
fprintf(fid,'*BOUNDARY\n');
fprintf(fid,'fixed_nodes, 1, 6, 0.\n');
fprintf(fid,'*STEP, NAME=STEP-1, PERTURBATION\n');
fprintf(fid,'*STATIC\n');
fprintf(fid,'*CLOAD\n');
fprintf(fid,'moved_nodes,3,10000\n');
fprintf(fid,'*NODE PRINT\n');
fprintf(fid,'U\n');
fprintf(fid,'RF\n');
fprintf(fid,'*END STEP\n');
fclose(fid);