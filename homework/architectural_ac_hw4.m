function architectural_ac_hw4()
    problem1()
end

function problem1()

    porosity = 0.8;
    flow_res = 30000;
    rho_panel = 50;
    thickness = 0.05; % meters
    
    c_air =   343;
    rho_air = 412/c_air;
    p0c0 = c_air * rho_air;
    
    figure();
    
    numfreq = 500;
    
    f = linspace(16,32000,numfreq);
    w =  rho_air.*c_air.*(1+0.0571.*(rho_air.*f./flow_res).^(-0.754));
    x = -rho_air.*c_air.*(  0.0870.*(rho_air.*f./flow_res).^(-0.732));
    Z_m = w + 1j.*x;
    
    beta = (1./f).*(1+0.0978.*(rho_air.*f./flow_res).^(-0.7));
    delta  = (1./f).*(0.189.*(rho_air.*f./flow_res).^(-0.595));
    q = delta + 1j.*beta;
    
    z_rat = Z_m./(rho_air.*c_air);
    alpha_n = 1 - abs( (z_rat-1) ./ (z_rat+1) ).^2;
    
    loglog(f,alpha_n);
    
    numtheta = 200;
    theta = linspace(0,pi/2,numtheta)';
    Z_m   = repmat(Z_m,numtheta,1);
    theta = repmat(theta,1,numfreq);
    
    z_rat = Z_m./(rho_air.*c_air);
    alpha_theta = 1 - abs( (z_rat-1).*cos(theta) ./ (z_rat+1) ).^2;
    alpha_rand = mean(2.*alpha_theta.*sin(theta).*cos(theta),1);
    hold on;
    loglog(f,alpha_rand,'r');
    xlabel('Frequency - Hz');
    ylabel('Normal(b) and Random(r) Absorption Coef(\alpha)');
    
    figure();
    
    % With backing now:
    numL= 400;
    numfreq = 32;
    %f = repmat(linspace(16,32000,numfreq),numL,1);
    f = repmat(2.^(linspace(4,16,numfreq)),numL,1);
    L = repmat(linspace(0,1,numL)',1,numfreq);
    r_f = flow_res*thickness;
    L_lambda = (c_air ./f) .* L;
    d = L_lambda;
    %d = 0.25*c_air/1000;
    omega_r = sqrt(rho_air*c_air*c_air./(rho_panel.*thickness.*d));
    % using d=L_lambda in eq 7.102:
    %numerator = (4*r_f*rho_air*c_air);
    %dterm1 = (r_f + rho_air*c_air)^2;
    %dterm2 = (rho_panel.*thickness./(2.*pi.*f).*((2.*pi.*f).^2 - omega_r.^2)).^2;
    %dterm2 = (rho_panel.*thickness./(f).*(f.^2 - omega_r.^2)).^2;
    %alpha_n = numerator./(dterm1 + dterm2);
    % using Eq 7.78
    term1 = (sqrt(r_f/p0c0) + sqrt(p0c0/r_f))^2;
    term2 = p0c0./r_f .* cot(2.*pi.*f.*d./c_air).^2;
    alpha_n = 4./(term1+term2);
    
    imagesc(f(1,:),L(:,1),(alpha_n));
    xlabel('Freqency - Hz');
    ylabel('Backing Distance - L/\lambda');
    title('Normal-incidence Absoption of an air-backed porous material');
end