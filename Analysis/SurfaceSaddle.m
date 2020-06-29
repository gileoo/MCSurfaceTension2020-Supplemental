function [] = SurfaceSaddle( file_name )

    % read exported simulation surface data 
    T = readtable( file_name, 'HeaderLines', 1);

    X  = T(:,1);
    Y  = T(:,2);
    Z  = T(:,3);
    C1 = T(:,4);
    C2 = T(:,5);
    
    P = table2array( [X, Z, Y] );
    C = table2array( [C1, C2] );
    
    s = size(P);
    
    count = 0;
    
    psize = 0.06;
    
    for k = 1 : s(1)
        
        if( onBorder( P(k, :), psize ) )
            count = count + 1;
        end
        
    end
    
    PB = zeros( count, 3 );
    CB = zeros( count, 2 );
    
    PI = zeros( s(1) - count, 3);
    CI = zeros( s(1) - count, 2);
    
    count  = 1;
    counti = 1;
    for k = 1 : s(1)
        
        if( onBorder( P(k, :), psize ) )    
            PB(count, :) = P(k, :);
            CB(count, :) = C(k, :);
            count = count + 1;
        else
            PI(counti, :) = P(k, :);
            CI(counti, :) = C(k, :);
            counti = counti + 1;
        end
    end
      

do3D = false;
    
if( do3D )    
    ptCloud = pointCloud( [PB(:,1), PB(:,2), PB(:,3) ] );
    pcshow( ptCloud, 'MarkerSize', 500  );
    colormap( [linspace(0.0, 0.8, 100)', linspace(0.0, 0.8, 100)', ones(100,1)] )
else      
    scatter( CI(:,1), CI(:,2), 'MarkerFaceColor', [0.0, 1.0, 0.0], 'MarkerEdgeColor',  [0.0, 1.0, 0.0] )
    hold on;

    scatter( CB(:,1), CB(:,2), 'filled', 'MarkerFaceColor', [0.0, 0.0, 1.0], 'MarkerEdgeColor',  [0.0, 0.0, 1.0] )

    [hb, xb] = hist( CB(:,1), 30 );
    bar( xb, hb/2000*200, 'FaceColor', 'b' ) 
    
    [hi, xi] = hist( CI(:,1), 60 );
    %bar( xi, hi/2000*30, 'FaceColor', 'g' ) 
    
    plot( [0.0, 1.0]', [13; 13 + 74.69]', 'LineWidth', 2.0, 'color', [0.5, 0.5, 0.5] )
    plot( [0.0, 1.0]', [28; 28 + 74.69]', 'LineWidth', 2.0, 'color', [0.75, 0.75, 0.75] )
end
    
    fsize1 = 40*1.5;
    fsize2 = 28*1.5;
    
    set(gcf,'color','w' );
    set(gca,'color','w','FontName', 'Palatino Linotype', 'FontSize', fsize2 );
    set(gca, 'XColor', [0.15 0.15 0.15], ...
        'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15]...
        ,'FontName', 'Palatino Linotype', 'FontSize', fsize2 )
       
end

function [b] = onBorder( p, d )

    b = false;
    
    x = p(1);
    y = p(2);
    z = p(3);

    zd = 0.8 * d;
    o = 0.0;
    surf = 1.12;
    
    %if( x < 0.0 )
    if( ( abs( x ) < 1.0 + d  && ...
          abs( x ) > 1.0 - d ) || ...
        ( abs( y ) < 1.0 + d  && ...
          abs( y ) > 1.0 - d ) || ... 
        ( z < o + x^2-y^2 + zd * sqrt( 1 + 4*x*x ) + zd * sqrt( 1 + 4*y*y ) && ...
          z > o + x^2-y^2 - zd * sqrt( 1 + 4*x*x ) + zd * sqrt( 1 + 4*y*y ) ) || ...
        ( z < surf + d && z > surf - d )  )    
        b = true;
    end
   % end

end