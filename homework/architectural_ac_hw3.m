function architectural_ac_hw3
    problem1();
    problem2();
end

function problem1()

    fprintf('---- Problem 1 ----\n');
    room_length=25; %ft
    room_width=20; %ft
    room_height=9; %ft
    
    c0 = 343; % m/s
    
    meters_per_foot = .3048; % m/ft
    lx = room_length * meters_per_foot;
    ly = room_width * meters_per_foot;
    lz = room_height * meters_per_foot;
    
    jmode = 1;
    jx_max = 10;
    jy_max = 10;
    jz_max = 10;
    modes = [];
    for jx = 0:jx_max
        for jy = 0:jy_max
            for jz = 0:jz_max
                modes(:,jmode) = [jx;jy;jz];
                jmode = jmode+1;
            end
        end
    end
    
    % skip mode 000
    modes = modes(:,2:end);
    
    sizes_mat = repmat([lx;ly;lz],1,size(modes,2));
    
    nat_freqs = c0*0.5*sqrt(sum((modes./sizes_mat).^2,1));
    
    [~,jmode_by_freq] = sort(nat_freqs);
    
    fprintf('Finding the 8 lowest frequency modes, excluding 000\n')
    
    f_ax = 1:300;
    figure();
    hold on
    plot(f_ax,num_modes(f_ax,[lx,ly,lz]));
    plot(nat_freqs(jmode_by_freq),1:length(jmode_by_freq),'r.');
    xlabel('Frequency - Hz');
    ylabel('Number of Modes');
    
    for kmode=1:16
        fprintf('Mode %2d: %5.1f Hz mode=%d%d%d\n',kmode,nat_freqs(jmode_by_freq(kmode)), ...
            modes(1:3,jmode_by_freq(kmode)));
    end
    
    % I recall there being a single peak for each mode
    mode_220 = image_mode_pressure([2 2 0],[lx ly lz]);
    %first8_modes = modes(:,jmode_by_freq(1:8))';
    %rms = image_mode_pressure(first8_modes,[lx ly lz]);
    
end


function rms_pressure = image_mode_pressure(modes,room_size)

    x_mode_num = modes(:,1);
    y_mode_num = modes(:,2);
    z_mode_num = modes(:,3);
    lx = room_size(1);
    ly = room_size(2);
    lz = room_size(3);
    
    res = 0.01; % resolution of room image, meters.
    % compute p = 8*A*cos((n_x * pi * x)/l_x) * cos(n_y ... ) * cos(n_z ...
    % ) * e^jwt. ( see Long: Eqn (8.42) )
    x_ax = [0:res:lx];
    y_ax = [0:res:ly];
    measure_height = 2; % (meters) sample at satanding person height
    x_grid = repmat(x_ax',1,length(y_ax));
    y_grid = repmat(y_ax, length(x_ax),1);
    
    x_mode_num = repmat(x_mode_num,[1,length(x_ax),length(y_ax)]);
    y_mode_num = repmat(y_mode_num,[1,length(x_ax),length(y_ax)]);
    z_mode_num = repmat(z_mode_num,[1,length(x_ax),length(y_ax)]);
    x_grid0(1,:,:) = x_grid;
    x_grid = repmat(x_grid0,[size(modes,1),1,1]);
    y_grid0(1,:,:) = y_grid;
    y_grid = repmat(y_grid0,[size(modes,1),1,1]);
    
    x_portion = cos(x_grid.*(x_mode_num.*pi./lx));
    y_portion = cos(y_grid.*(y_mode_num.*pi./ly));
    z_portion = cos(measure_height.*z_mode_num.*pi./ly);
    
    
    % using the fact that RMS of sinusoid is A/sqrt(2)
    rms_pressure = abs(8.*x_portion.*y_portion.*z_portion./sqrt(2));
    rms_pressure = squeeze(mean(rms_pressure,1));
    figure(); 
    
    imagesc(x_ax,y_ax,rms_pressure);
    set(gca,'YDir','Normal');
    axis('equal')
end

function f0 = mode_freq(modes,room_size)
    % modes is [ 3 x nmodes ] and room_size is [3 x 1]
    % returns f0 [ 1 x nmodes ] center frequencies
    c0 = 343;
    sizes_mat = repmat(room_size,1,size(modes,2));
    f0 = c0*0.5*sqrt(sum((modes./sizes_mat).^2,1));
end

function [Nf,Na,Nt,No] = num_modes(f,room_size)
    c0 = 343;
    lx = room_size(1);
    ly = room_size(2);
    lz = room_size(3);
    V = lx*ly*lz;
    S = 2*lx*ly + 2*lx*lz + 2*ly*lz;
    L = 4*lx + 4*ly + 4*lz;
    No = (4.*pi./3).*V.*(f./c0).^3;
    Nt = (pi./4).*S.*(f./c0).^2;
    Na = (L./8).*(f./c0);
    Nf = Na + Nt + No;
end

function Nf_df = num_modes_per_freq(f,room_size)
    c0 = 343;
    lx = room_size(1);
    ly = room_size(2);
    lz = room_size(3);
    V = lx*ly*lz;
    S = 2*lx*ly + 2*lx*lz + 2*ly*lz;
    L = 4*lx + 4*ly + 4*lz;
    Nf_df = (4*pi.*V).*(f.^2 ./ c0^3) + ...
        (pi/2).*S.*(f./c0^2) + ...
        L./(8*c0);
end

function problem2()
    room_size = [4.64; 3.68; 2.92];
    band_centers = zeros(1,11);
    band_centers(11)=16000;
    for jb=10:-1:1
        band_centers(jb) = band_centers(jb+1)/2;
    end
    
    band_low = band_centers./sqrt(2);
    band_hi  = band_centers.*sqrt(2);
    [tot0,a0,t0,o0] = num_modes(band_low,room_size);
    [tot1,a1,t1,o1] = num_modes(band_hi,room_size);
    freqs_in_band = tot1 - tot0;
    axial      = a1 - a0;
    tangential = t1 - t0;
    oblique    = o1 - o0;
    
    figure();
    opts = {'LineWidth',1.25};
    loglog(band_centers,freqs_in_band,'k','DisplayName','Total Modes',opts{:});
    hold on
    loglog(band_centers,axial,'b','DisplayName','Axial Modes',opts{:});
    loglog(band_centers,tangential,'r','DisplayName','Tangential Modes',opts{:});
    loglog(band_centers,oblique,'g','DisplayName','Oblique Modes',opts{:});
    grid on
    legend show
    xlabel('Band Center - Hz');
    ylabel('Modes in Band');
    
    
    nmax = 85+1;
    counter = (0:nmax^3);
    xmodes = mod(floor(counter/nmax.^2),nmax);
    ymodes = mod(floor(counter/nmax.^1),nmax);
    zmodes = mod(floor(counter/nmax.^0),nmax);
    modes = [xmodes; ymodes; zmodes];
    modes = modes(:,2:end);
    
    freqs = mode_freq(modes,room_size);
    [freqs,ii] = sort(freqs);
    modes = modes(:,ii);
    
    ii_take = freqs<5000;
    modes = modes(:,ii_take);
    freqs = freqs(ii_take);
    
    on_off = modes>0;
    axial = sum(on_off,1) == 1;
    tangential = sum(on_off,1) == 2;
    oblique = sum(on_off,1) == 3;

    % determine the length of each of the k-space axis vectors (pi/l)
    k_basis = pi./room_size;
    % translate mode number integers into k-space vectors
    k_space_vec = modes .* repmat(k_basis,1,size(modes,2));
    
    % compute sin(theta_psi) = k_space_psi/length of k-space vector
    %   for psi as x,y,z (aka indexes 1 2 3 in our k_space_vec)
    % start with finding the k-space vector length for every mode
    vec_lengths = sqrt(sum(k_space_vec.^2,1));
    % and (for vectorization) match its size to the whole k-space vector
    % matrix.
    vec_lengths = repmat(vec_lengths,3,1);
    % compute the k-space arrival angle.  theta(1,:) is theta_x, etc
    thetas = asind(k_space_vec./vec_lengths);
    figure();
    semilogx(freqs(axial),thetas(1,axial),'b.');
    hold on
    semilogx(freqs(tangential),thetas(2,tangential),'r.');
    semilogx(freqs(oblique),thetas(3,oblique),'g.');
    xlabel('Frequency - Hz');
    ylabel('K-Space Angle - Degrees');
    title('K-Space Angle for Axial(b), Tangential(r) and Oblique(g) modes');
end