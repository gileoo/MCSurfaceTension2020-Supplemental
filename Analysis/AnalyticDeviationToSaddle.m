
function [] = AnalyticDeviationToSaddle( file_name, geometry, plot_it, part_radius )

    % read exported simulation surface data 
    T = readtable( file_name, 'HeaderLines', 1);

    X = T(:,1);
    Y = T(:,2);
    Z = T(:,3);
    NX = T(:,4);
    NY = T(:,5);
    NZ = T(:,6);
    NSX = T(:,7);
    NSY = T(:,8);
    NSZ = T(:,9);
    NPX = T(:,10);
    NPY = T(:,11);
    NPZ = T(:,12);
    
    P = table2array( [X, Z, Y] );
    N = table2array( [NX, NZ, NY] );
    NS = table2array( [NSX, NSZ, NSY] );
    NP = table2array( [NPX, NPZ, NPY] );

    crossAxis  = 1;
    crossPos   = 0.0;
    crossWidth = 1.0; %0.1;
    
    [P, N, NS, NP] = filterCross( P, N, NS, NP, crossAxis, crossPos, crossWidth );
    
    C          = filterCross1( P, table2array( T(:,13) ), crossAxis, crossPos, crossWidth );
    CCrr       = filterCross1( P, table2array( T(:,14) ), crossAxis, crossPos, crossWidth );
    CSmo       = filterCross1( P, table2array( T(:,15) ), crossAxis, crossPos, crossWidth );
    CN         = filterCross1( P, table2array( T(:,16) ), crossAxis, crossPos, crossWidth );
    CNSmo      = filterCross1( P, table2array( T(:,17) ), crossAxis, crossPos, crossWidth );
    Csph       = filterCross1( P, table2array( T(:,18) ), crossAxis, crossPos, crossWidth );
    CsphSmo    = filterCross1( P, table2array( T(:,19) ), crossAxis, crossPos, crossWidth );
    Samples    = filterCross1( P, table2array( T(:,20) ), crossAxis, crossPos, crossWidth );
    MaxSamples = filterCross1( P, table2array( T(:,21) ), crossAxis, crossPos, crossWidth );

    Pproj = projectHP( P, part_radius );
    
    s = size(P);
    s(2) = 1;
    
    if geometry == 'saddle'
        Za = cellfun(@HParaboloid,num2cell(P,2));
        T1 = [ones(s), zeros(s), 2.0 * P(:,1)];
        T2 = [zeros(s), ones(s), -2.0 * P(:,2)];
        NA = cross(T2, T1);
        Ha = cellfun(@SaddleC,num2cell(P,2));
              
        ZaPr = cellfun(@HParaboloidUp,num2cell(P,2));
        T1Pr = [ones(s), zeros(s), 2.0 * P(:,1) + 4 * P(:,1) * part_radius./sqrt(1+4.*P(:,1).*P(:,1))];
        T2Pr = [zeros(s), ones(s), -2.0 * P(:,2) + 4 * P(:,2) * part_radius./sqrt(1+4.*P(:,2).*P(:,2))];
        NAPr = cross(T2Pr, T1Pr);
        NAPr = normr(NAPr);
        HaPr = cellfun(@SaddleC,num2cell(P,2));
        
    else
        Za = cellfun(@HSphere,num2cell(P,2));
        NA = [P(:,1), P(:,2), Za] - [0, 0, 1.6];
        Ha = cellfun(@SphereC,num2cell(P,2));
    end

    
    % analytic normal
    NALen = cellfun(@norm,num2cell(NA,2));
    NAn = NA ./ NALen;
    Zdiff = Za - P(:,3);

    
    % curvature
    Cdiff = abs( Ha - CSmo );
       
    ptCloud = pointCloud( [P(:,1), P(:,2), P(:,3) ], 'Intensity', CSmo );
    ptCloudA = pointCloud( [P(:,1), P(:,2), Za ],  'Intensity', Ha );
    
    
    
    %ptCloudPr = pointCloud( [P(:,1), P(:,2), ZaPr ], 'Intensity', HaPr );
    ptCloudPr = pointCloud( [P(:,1), P(:,2), ZaPr ] );
    
    % pca normals
    Npca = pcnormals(ptCloud, 6);

    % Flip the normals to point towards the sensor location.
    sensorCenter = [0, 0, 10]; 
    for k = 1 : s
       p1 = sensorCenter - [P(k,1),P(k,2),P(k,3)];
       p2 = [Npca(k,1),Npca(k,2),Npca(k,3)];
       % Flip the normal vector if it is pointing towards the sensor.
       angle = atan2(norm(cross(p1,p2)), p1*p2');
       if angle < pi/2 && angle > -pi/2
           Npca(k,1) = -Npca(k,1);
           Npca(k,2) = -Npca(k,2);
           Npca(k,3) = -Npca(k,3);
       end
    end
    
    fsize1 = 40*1.5;
    fsize2 = 28*1.5;
    
    if plot_it == 'plot'
        figure      
        hold on
        %pcshow( ptCloudA, 'MarkerSize', 400 );
        %hold on
        pcshow( ptCloud, 'MarkerSize', 3000  );
        colormap( getColorMapBWR(0.0) )
        
        hold on

        %pcshow( ptCloudPr, 'MarkerSize', 800  );
        
        %colormap( [0,0,0] )
        
        %colormap( getColorMapBWR(-1.0) )

        
        %colorbar
        %quiver3( P(:,1), P(:,2), P(:,3), ...
        %         N(:,1), N(:,2), N(:,3), 'color',[1 0 0] )


             
%        xlabel('X','FontName', 'Palatino Linotype', 'FontSize', fsize1 );
%        ylabel('Y','FontName', 'Palatino Linotype', 'FontSize', fsize1 );
%        zlabel('Z','FontName', 'Palatino Linotype', 'FontSize', fsize1 );
        set(gcf,'color','w' );
        set(gca,'color','w','FontName', 'Palatino Linotype', 'FontSize', fsize2 );
        set(gca, 'XColor', [0.15 0.15 0.15], ...
            'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15]...
            ,'FontName', 'Palatino Linotype', 'FontSize', fsize2 )
    
        %quiver3( P(:,1), P(:,2), P(:,3), NAn(:,1), NAn(:,2), NAn(:,3), ...
        %         'color',[0 1 0]  );
  
        %{
        quiver3( P(:,1), P(:,2), P(:,3), NAPr(:,1), NAPr(:,2), NAPr(:,3), ...
                 'color',[0 0 0], 'LineWidth', 2.0  );

        quiver3(P(:,1), P(:,2), P(:,3), N(:,1), N(:,2), N(:,3), ...
            'color',[1 0 0], 'LineWidth', 2.0   );
             
        quiver3(P(:,1), P(:,2), P(:,3), Npca(:,1), Npca(:,2), Npca(:,3), ...
                'color',[0 0 1], 'LineWidth', 2.0  );
         %}
   
%        quiver3(P(:,1), P(:,2), P(:,3), NP(:,1), NP(:,2), NP(:,3), ...
%                'color',[0 0 1]  );            
           
    end
%    NAn(20,:)
%    N(20,:)
    
%    cosphi =  dot( NAn(20,:), N(20,:) )
%    ang1 = abs( acos( cosphi ) / pi * 180 )
    
    cPhiPr = acos( dot( NAPr', NAn' ) );
    angPr = abs( cPhiPr' / pi * 180 );
    
    % statistics of the angle per point
    AngPrAAvg   = mean( angPr );
    AngPrAMin   = min( angPr );
    AngPrAMax   = max( angPr );
    AngPrAStd   = std( angPr );
    AngPrAMnD   = mad( angPr, 0 );
    AngPrAMdD   = mad( angPr, 1 );

    %NAn = NAPr;
    
    % measure deviation by dot product of normals
    % converted to angels
    cPhi = acos( dot( NAn', N' ) );
    ang = abs( cPhi' / pi * 180 );
    
    % statistics of the angle per point
    AngDAAvg   = mean( ang );
    AngDAMin   = min( ang );
    AngDAMax   = max( ang );
    AngDAStd   = std( ang );
    AngDAMnD   = mad( ang, 0 );
    AngDAMdD   = mad( ang, 1 );
    
    cPhiS = acos( dot( NAn', NS' ) );
    angS = abs( cPhiS' / pi * 180 );
    
    % statistics of the angle per point
    AngDSAAvg   = mean( angS );
    AngDSAMin   = min( angS );
    AngDSAMax   = max( angS );
    AngDSAStd   = std( angS );
    AngDSAMnD   = mad( angS, 0 );
    AngDSAMdD   = mad( angS, 1 );

    
    cPhiPca = acos( dot( NAn', Npca' ) );
    angPca = abs( cPhiPca' / pi * 180 );
 
    % statistics of the angle per point for matlab pca
    AngPAAvg = mean( angPca );
    AngPAMin = min( angPca );
    AngPAMax = max( angPca );
    AngPAStd = std( angPca );
    AngPAMnD = mad( angPca, 0 ); % mean dev
    AngPAMdD = mad( angPca, 1 ); % median dev
    
    cPhiPca2 = acos( dot( NAn', NP' ) );
    angPca2 = abs( cPhiPca2' / pi * 180 );

    
    % statistics of the angle per point for matlab pca
    AngPAAvg2 = mean( angPca2 );
    AngPAMin2 = min( angPca2 );
    AngPAMax2 = max( angPca2 );
    AngPAStd2 = std( angPca2 );
    AngPAMnD2 = mad( angPca2, 0 ); % mean dev
    AngPAMdD2 = mad( angPca2, 1 ); % median dev
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    boxdata  = [ang;angS;angPca;angPca2];
%    boxgroup = [ones(size(ang)); 2*ones(size(angS)); 3*ones(size(angPca)); 4*ones(size(angPca2))];
%    boxplot(boxdata,boxgroup)
   
%    ylim([0.0 30.0])
    
%    set(findobj(gca,'type','line'),'linew',2)
%    set(gca,'color','w','FontName', 'Palatino Linotype', 'FontSize', fsize2 );
    
%    set(gcf,'position',[1200,200,512,512]) 
    
    %Ka = cellfun(@SaddleK,num2cell(P,2));

    
    % statistics of the mean curvature per point
    CurDAAvg = mean( Cdiff );
    CurDAMin = min( Cdiff );
    CurDAMax = max( Cdiff );
    CurDAStd = std( Cdiff );
    CurDAMnD = mad( Cdiff, 0 );
    CurDAMdD = mad( Cdiff, 1 );
       
    fileIDS = fopen( strcat(file_name, geometry, '.stats.csv'),'w');
    fileIDD = fopen( strcat(file_name, geometry, '.dat.csv'),'w');
    
    % AngDAAvg -> Angle, ZorillaNormal versus Analytic, Average
    % AngPAAvg -> Angle, PCANormal versus Analytic, Average
    % Caverage
    
    fprintf(fileIDS, "NrPts, AngDAAvg, AngDAMin, AngDAMax, AngDAStd, AngDAMnD, AngDAMdD, AngPAAvg, AngPAMin, AngPAMax, AngPAStd, AngPAMnD, AngPAMdD, AngPAAvg2, AngPAMin2, AngPAMax2, AngPAStd2, AngPAMnD2, AngPAMdD2, CurDAAvg, CurDAMin, CurDAMax, CurDAStd, CurDAMnD, CurDAMdD\n");
    fprintf(fileIDS, '%d, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f\n', ...
        s(1), AngDAAvg, AngDAMin, AngDAMax, AngDAStd, AngDAMnD, AngDAMdD, ... 
        AngPAAvg, AngPAMin, AngPAMax, AngPAStd, AngPAMnD, AngPAMdD, ...
        AngPAAvg2, AngPAMin2, AngPAMax2, AngPAStd2, AngPAMnD2, AngPAMdD2, ...
        CurDAAvg, CurDAMin, CurDAMax, CurDAStd, CurDAMnD, CurDAMdD );
    fclose(fileIDS);
    
    fprintf(fileIDD, "AngDA, AngPA, CurDA\n");
    
    for k = 1 : s
        fprintf(fileIDD, '%.2f, %.2f, %.2f\n', ang(k), angPca(k), Cdiff(k) );
    end
    
    fclose(fileIDD);
    

end

function K = SaddleK( p )
    x = p(1);
    y = p(2);
    K = -4.0 / ((1.0 + 4.0*x*x + 4.0*y*y )^2);
end

function C = SaddleC( p )
    x = p(1);
    y = p(2);
    C = (-4.0*x*x + 4.0*y*y) / sqrt( (1.0 + 4.0*x*x + 4.0*y*y)^3 );
end

function C = SphereC( p )
    C= 1.0/1.6;
end

function Z = HParaboloid( p )
    x = p(1);
    y = p(2);
    Z = x*x - y*y;
end

function Z = HParaboloidUp( p )
    x = p(1);
    y = p(2);
    r = 0.03;
    Z = x*x - y*y + r * sqrt( 1 + 4*x*x ) + r * sqrt( 1 + 4*y*y );
end



function Z = HSphere( p )
    x = p(1);
    y = p(2);
    r = 1.6;
    Z = r - sqrt( r*r - x*x - y*y);
end

function c = getColorMapBWR(offset)
    c = [
    [ 1.000000,0.000000,0.000000 ],
	[ 1.000000,0.000848,0.000848 ],
	[ 1.000000,0.001709,0.001709 ],
	[ 1.000000,0.002584,0.002584 ],
	[ 1.000000,0.003473,0.003473 ],
	[ 1.000000,0.004375,0.004375 ],
	[ 1.000000,0.005292,0.005292 ],
	[ 1.000000,0.006224,0.006224 ],
	[ 1.000000,0.007170,0.007170 ],
	[ 1.000000,0.008133,0.008133 ],
	[ 1.000000,0.009111,0.009111 ],
	[ 1.000000,0.010105,0.010105 ],
	[ 1.000000,0.011116,0.011116 ],
	[ 1.000000,0.012144,0.012144 ],
	[ 1.000000,0.013190,0.013190 ],
	[ 1.000000,0.014254,0.014254 ],
	[ 1.000000,0.015336,0.015336 ],
	[ 1.000000,0.016436,0.016436 ],
	[ 1.000000,0.017557,0.017557 ],
	[ 1.000000,0.018697,0.018697 ],
	[ 1.000000,0.019857,0.019857 ],
	[ 1.000000,0.021039,0.021039 ],
	[ 1.000000,0.022242,0.022242 ],
	[ 1.000000,0.023467,0.023467 ],
	[ 1.000000,0.024715,0.024715 ],
	[ 1.000000,0.025986,0.025986 ],
	[ 1.000000,0.027282,0.027282 ],
	[ 1.000000,0.028602,0.028602 ],
	[ 1.000000,0.029947,0.029947 ],
	[ 1.000000,0.031318,0.031318 ],
	[ 1.000000,0.032717,0.032717 ],
	[ 1.000000,0.034143,0.034143 ],
	[ 1.000000,0.035597,0.035597 ],
	[ 1.000000,0.037081,0.037081 ],
	[ 1.000000,0.038595,0.038595 ],
	[ 1.000000,0.040140,0.040140 ],
	[ 1.000000,0.041718,0.041718 ],
	[ 1.000000,0.043328,0.043328 ],
	[ 1.000000,0.044973,0.044973 ],
	[ 1.000000,0.046652,0.046652 ],
	[ 1.000000,0.048368,0.048368 ],
	[ 1.000000,0.050122,0.050122 ],
	[ 1.000000,0.051914,0.051914 ],
	[ 1.000000,0.053746,0.053746 ],
	[ 1.000000,0.055620,0.055620 ],
	[ 1.000000,0.057536,0.057536 ],
	[ 1.000000,0.059496,0.059496 ],
	[ 1.000000,0.061502,0.061502 ],
	[ 1.000000,0.063556,0.063556 ],
	[ 1.000000,0.065658,0.065658 ],
	[ 1.000000,0.067810,0.067810 ],
	[ 1.000000,0.070016,0.070016 ],
	[ 1.000000,0.072275,0.072275 ],
	[ 1.000000,0.074591,0.074591 ],
	[ 1.000000,0.076965,0.076965 ],
	[ 1.000000,0.079400,0.079400 ],
	[ 1.000000,0.081897,0.081897 ],
	[ 1.000000,0.084460,0.084460 ],
	[ 1.000000,0.087091,0.087091 ],
	[ 1.000000,0.089792,0.089792 ],
	[ 1.000000,0.092566,0.092566 ],
	[ 1.000000,0.095416,0.095416 ],
	[ 1.000000,0.098346,0.098346 ],
	[ 1.000000,0.101358,0.101358 ],
	[ 1.000000,0.104456,0.104456 ],
	[ 1.000000,0.107643,0.107643 ],
	[ 1.000000,0.110923,0.110923 ],
	[ 1.000000,0.114301,0.114301 ],
	[ 1.000000,0.117781,0.117781 ],
	[ 1.000000,0.121366,0.121366 ],
	[ 1.000000,0.125062,0.125062 ],
	[ 1.000000,0.128874,0.128874 ],
	[ 1.000000,0.132806,0.132806 ],
	[ 1.000000,0.136866,0.136866 ],
	[ 1.000000,0.141057,0.141057 ],
	[ 1.000000,0.145388,0.145388 ],
	[ 1.000000,0.149864,0.149864 ],
	[ 1.000000,0.154492,0.154492 ],
	[ 1.000000,0.159281,0.159281 ],
	[ 1.000000,0.164237,0.164237 ],
	[ 1.000000,0.169370,0.169370 ],
	[ 1.000000,0.174689,0.174689 ],
	[ 1.000000,0.180202,0.180202 ],
	[ 1.000000,0.185922,0.185922 ],
	[ 1.000000,0.191857,0.191857 ],
	[ 1.000000,0.198020,0.198020 ],
	[ 1.000000,0.204423,0.204423 ],
	[ 1.000000,0.211080,0.211080 ],
	[ 1.000000,0.218005,0.218005 ],
	[ 1.000000,0.225212,0.225212 ],
	[ 1.000000,0.232717,0.232717 ],
	[ 1.000000,0.240539,0.240539 ],
	[ 1.000000,0.248695,0.248695 ],
	[ 1.000000,0.257204,0.257204 ],
	[ 1.000000,0.266088,0.266088 ],
	[ 1.000000,0.275369,0.275369 ],
	[ 1.000000,0.285070,0.285070 ],
	[ 1.000000,0.295218,0.295218 ],
	[ 1.000000,0.305838,0.305838 ],
	[ 1.000000,0.316961,0.316961 ],
	[ 1.000000,0.328615,0.328615 ],
	[ 1.000000,0.340834,0.340834 ],
	[ 1.000000,0.353651,0.353651 ],
	[ 1.000000,0.367103,0.367103 ],
	[ 1.000000,0.381227,0.381227 ],
	[ 1.000000,0.396064,0.396064 ],
	[ 1.000000,0.411653,0.411653 ],
	[ 1.000000,0.428038,0.428038 ],
	[ 1.000000,0.445262,0.445262 ],
	[ 1.000000,0.463368,0.463368 ],
	[ 1.000000,0.482402,0.482402 ],
	[ 1.000000,0.502406,0.502406 ],
	[ 1.000000,0.523421,0.523421 ],
	[ 1.000000,0.545486,0.545486 ],
	[ 1.000000,0.568635,0.568635 ],
	[ 1.000000,0.592898,0.592898 ],
	[ 1.000000,0.618294,0.618294 ],
	[ 1.000000,0.644834,0.644834 ],
	[ 1.000000,0.672519,0.672519 ],
	[ 1.000000,0.701332,0.701332 ],
	[ 1.000000,0.731243,0.731243 ],
	[ 1.000000,0.762202,0.762202 ],
	[ 1.000000,0.794140,0.794140 ],
	[ 1.000000,0.826968,0.826968 ],
	[ 1.000000,0.860577,0.860577 ],
	[ 1.000000,0.894837,0.894837 ],
	[ 1.000000,0.929603,0.929603 ],
	[ 1.000000,0.964714,0.964714 ],
	[ 0.964714,0.964714,1.00 ],
	[ 0.929603,0.929603,1.00 ],
	[ 0.894837,0.894837,1.00 ],
	[ 0.860577,0.860577,1.00 ],
	[ 0.826968,0.826968,1.00 ],
	[ 0.794140,0.794140,1.00 ],
	[ 0.762202,0.762202,1.00 ],
	[ 0.731243,0.731243,1.00 ],
	[ 0.701332,0.701332,1.00 ],
	[ 0.672519,0.672519,1.00 ],
	[ 0.644834,0.644834,1.00 ],
	[ 0.618294,0.618294,1.00 ],
	[ 0.592898,0.592898,1.00 ],
	[ 0.568635,0.568635,1.00 ],
	[ 0.545486,0.545486,1.00 ],
	[ 0.523421,0.523421,1.00 ],
	[ 0.502406,0.502406,1.00 ],
	[ 0.482402,0.482402,1.00 ],
	[ 0.463368,0.463368,1.00 ],
	[ 0.445262,0.445262,1.00 ],
	[ 0.428038,0.428038,1.00 ],
	[ 0.411653,0.411653,1.00 ],
	[ 0.396064,0.396064,1.00 ],
	[ 0.381227,0.381227,1.00 ],
	[ 0.367103,0.367103,1.00 ],
	[ 0.353651,0.353651,1.00 ],
	[ 0.340834,0.340834,1.00 ],
	[ 0.328615,0.328615,1.00 ],
	[ 0.316961,0.316961,1.00 ],
	[ 0.305838,0.305838,1.00 ],
	[ 0.295218,0.295218,1.00 ],
	[ 0.285070,0.285070,1.00 ],
	[ 0.275369,0.275369,1.00 ],
	[ 0.266088,0.266088,1.00 ],
	[ 0.257204,0.257204,1.00 ],
	[ 0.248695,0.248695,1.00 ],
	[ 0.240539,0.240539,1.00 ],
	[ 0.232717,0.232717,1.00 ],
	[ 0.225212,0.225212,1.00 ],
	[ 0.218005,0.218005,1.00 ],
	[ 0.211080,0.211080,1.00 ],
	[ 0.204423,0.204423,1.00 ],
	[ 0.198020,0.198020,1.00 ],
	[ 0.191857,0.191857,1.00 ],
	[ 0.185922,0.185922,1.00 ],
	[ 0.180202,0.180202,1.00 ],
	[ 0.174689,0.174689,1.00 ],
	[ 0.169370,0.169370,1.00 ],
	[ 0.164237,0.164237,1.00 ],
	[ 0.159281,0.159281,1.00 ],
	[ 0.154492,0.154492,1.00 ],
	[ 0.149864,0.149864,1.00 ],
	[ 0.145388,0.145388,1.00 ],
	[ 0.141057,0.141057,1.00 ],
	[ 0.136866,0.136866,1.00 ],
	[ 0.132806,0.132806,1.00 ],
	[ 0.128874,0.128874,1.00 ],
	[ 0.125062,0.125062,1.00 ],
	[ 0.121366,0.121366,1.00 ],
	[ 0.117781,0.117781,1.00 ],
	[ 0.114301,0.114301,1.00 ],
	[ 0.110923,0.110923,1.00 ],
	[ 0.107643,0.107643,1.00 ],
	[ 0.104456,0.104456,1.00 ],
	[ 0.101358,0.101358,1.00 ],
	[ 0.098346,0.098346,1.00 ],
	[ 0.095416,0.095416,1.00 ],
	[ 0.092566,0.092566,1.00 ],
	[ 0.089792,0.089792,1.00 ],
	[ 0.087091,0.087091,1.00 ],
	[ 0.084460,0.084460,1.00 ],
	[ 0.081897,0.081897,1.00 ],
	[ 0.079400,0.079400,1.00 ],
	[ 0.076965,0.076965,1.00 ],
	[ 0.074591,0.074591,1.00 ],
	[ 0.072275,0.072275,1.00 ],
	[ 0.070016,0.070016,1.00 ],
	[ 0.067810,0.067810,1.00 ],
	[ 0.065658,0.065658,1.00 ],
	[ 0.063556,0.063556,1.00 ],
	[ 0.061502,0.061502,1.00 ],
	[ 0.059496,0.059496,1.00 ],
	[ 0.057536,0.057536,1.00 ],
	[ 0.055620,0.055620,1.00 ],
	[ 0.053746,0.053746,1.00 ],
	[ 0.051914,0.051914,1.00 ],
	[ 0.050122,0.050122,1.00 ],
	[ 0.048368,0.048368,1.00 ],
	[ 0.046652,0.046652,1.00 ],
	[ 0.044973,0.044973,1.00 ],
	[ 0.043328,0.043328,1.00 ],
	[ 0.041718,0.041718,1.00 ],
	[ 0.040140,0.040140,1.00 ],
	[ 0.038595,0.038595,1.00 ],
	[ 0.037081,0.037081,1.00 ],
	[ 0.035597,0.035597,1.00 ],
	[ 0.034143,0.034143,1.00 ],
	[ 0.032717,0.032717,1.00 ],
	[ 0.031318,0.031318,1.00 ],
	[ 0.029947,0.029947,1.00 ],
	[ 0.028602,0.028602,1.00 ],
	[ 0.027282,0.027282,1.00 ],
	[ 0.025986,0.025986,1.00 ],
	[ 0.024715,0.024715,1.00 ],
	[ 0.023467,0.023467,1.00 ],
	[ 0.022242,0.022242,1.00 ],
	[ 0.021039,0.021039,1.00 ],
	[ 0.019857,0.019857,1.00 ],
	[ 0.018697,0.018697,1.00 ],
	[ 0.017557,0.017557,1.00 ],
	[ 0.016436,0.016436,1.00 ],
	[ 0.015336,0.015336,1.00 ],
	[ 0.014254,0.014254,1.00 ],
	[ 0.013190,0.013190,1.00 ],
	[ 0.012144,0.012144,1.00 ],
	[ 0.011116,0.011116,1.00 ],
	[ 0.010105,0.010105,1.00 ],
	[ 0.009111,0.009111,1.00 ],
	[ 0.008133,0.008133,1.00 ],
	[ 0.007170,0.007170,1.00 ],
	[ 0.006224,0.006224,1.00 ],
	[ 0.005292,0.005292,1.00 ],
	[ 0.004375,0.004375,1.00 ],
	[ 0.003473,0.003473,1.00 ],
	[ 0.002584,0.002584,1.00 ],
	[ 0.001709,0.001709,1.00 ],
	[ 0.000848,0.000848,1.00 ],
	[ 0.000000,0.000000,1.00 ]
    ];
    c = max( min( c + [offset, offset, offset], 1 ), 0 );
end



function  [p, n, ns, ps] = filterCross( ip, in, ins, ips, axis, pos, width )

    si = size(ip);
    si(1);
    
    count = 0;
    
    for i = 1 : si(1)
        pref = ip(i,:);
        
        if abs( pref(axis) - pos ) < width
            count = count + 1;
        end
    end

    
    p  =  zeros(count, 3);
    n  =  zeros(count, 3);
    ns =  zeros(count, 3);
    ps =  zeros(count, 3);
        
    idx = 1;
    for i = 1 : si(1)
        pref = ip( i, : );

        if abs( pref(axis) - pos ) < width
            p( idx, : )  = ip( i, : );
            n( idx, : )  = in( i, : );
            ns( idx, : ) = ins( i, : );
            ps( idx, : ) = ips( i, : );
            idx = idx + 1;
        end
    end
end


function  [a] = filterCross1( ip, A, axis, pos, width )

    si = size(ip);
    si(1);
    
    count = 0;
    
    for i = 1 : si(1)
        pref = ip(i,:);
        
        if abs( pref(axis) - pos ) < width
            count = count + 1;
        end
    end
    
    a  =  zeros(count, 1);
    
    idx = 1;
    for i = 1 : si(1)
        pref = ip( i, : );

        if abs( pref(axis) - pos ) < width
            a(idx) = A(i);
            idx = idx + 1;
        end
    end
end

function p = projectHP( ip, pSize )
    
    si = size(ip);

    p = zeros(si(1), 3);
    
    for i = 1 : si(1)
    
        dx = 2.0 * ip( i, 1);
        beta = tan( dx / 1 );
        xs = sin(beta) * pSize;
        zs = cos(beta) * pSize;
        ys = 0.0;
        
        p( i, : )  = [ ip(i,1)+xs, ip(i,2)+ys, ip(i,3)-zs ];
    end
end





%ptCloud = pointCloud( P );
%figure
%pcshow( ptCloud )