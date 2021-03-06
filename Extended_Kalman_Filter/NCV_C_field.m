%function [data,epsilon_v]= NCV_field(NAVDR, SOURCEXY, ACOUSTICRB, e_gps_interp, n_gps_interp) %MOOS data
function [data,epsilon_v,rho_bar,P_minus_out,S_out,K_out,z_k_out,F_out]=NCV_C_field(Interp) %PF data
steps=length(Interp.Time);
data=zeros(19,steps); %matrix for post-processing data

%Define boundary conditions
acoustic_bearing=90-(Interp.NAV_HEADING(1)-Interp.Bearing(1));
if acoustic_bearing>180
    acoustic_bearing=acoustic_bearing-360;
elseif acoustic_bearing<-180
    acoustic_bearing=acoustic_bearing+360;
end
source_x=Interp.Range(1)*cosd(acoustic_bearing);
source_y=Interp.Range(1)*sind(acoustic_bearing);

e0_pos=Interp.e_gps(1)-source_x;
n0_pos=Interp.n_gps(1)-source_y;

stw0=Interp.NAV_SPEED(1);
hdg0=90-Interp.NAV_HEADING(1);

e0_vel=stw0*cosd(hdg0);
n0_vel=stw0*sind(hdg0);

%Initialize state and measurement vectors
x_k_minus=[e0_pos;e0_vel;n0_pos;n0_vel;0;0];
data(1:6,1)=x_k_minus;
x_k_plus=x_k_minus;
data(7:12,1)=x_k_plus;
z_k_out=zeros(4,steps);
z_k_out(:,1)=x_k_minus(1:4,1);

%Define Q, the covariance matrix for noise associated with the state vector
var_Qp=5; % position
var_Qw=.1; % water referenced velocity
var_Qc=.01; % current velocity
Q=diag([var_Qp^2,var_Qw^2,var_Qp^2,var_Qw^2,var_Qc^2,var_Qc^2]);

%Define R, the covariance matrix associated with measurement error, value will be
%calculated during each step of the filter
var_Rr_r=10^2; % range
var_Ra_r=deg2rad(1^2); % azimuth
var_Rs_r=.1^2; % speed through the water
var_Ra1_r=deg2rad(1^2); % heading

%Initialize error covariance matrices
var_Pr=10^2; % position
var_Ps=10^2; % velocity
P_minus=diag([var_Pr,var_Ps,var_Pr,var_Ps,var_Ps,var_Ps]);
P_plus=P_minus;

%Define H, the measurement mapping matrix
H=[1 0 0 0 0 0;0 1 0 0 0 0;0 0 1 0 0 0;0 0 0 1 0 0];

%Initialize vectors for consistency checks
%epsilon=zeros(1,steps);
epsilon_v=zeros(1,steps);
%mu=zeros(length(x_k_plus),steps);
K_out=zeros(6,4,steps);
S_out=zeros(4,4,steps);
P_minus_out=zeros(6,6,steps);
F_out=zeros(6,6,steps);
%% Execute filter
for ii=2:steps
    dt=Interp.Time(ii)-Interp.Time(ii-1);
    F=[1 dt 0 0 dt 0;0 1 0 0 0 0;0 0 1 dt 0 dt;0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1]; % state transition matrix
    F_out(:,:,ii)=F;
    
    %Calculate state estimate and error covariance matrix for next step
    x_k_minus=F*x_k_plus;
    P_minus=F*P_plus*F.'+Q;
    P_minus_out(:,:,ii)=P_minus;    
    data(1:6,ii)=x_k_minus;
    
    %Calculate measurement vec and vector
    acoustic_bearing=90-(Interp.NAV_HEADING(ii)-Interp.Bearing(ii));
    if acoustic_bearing>180
        acoustic_bearing=acoustic_bearing-360;
    elseif acoustic_bearing<-180
        acoustic_bearing=acoustic_bearing+360;
    end
    
    range=Interp.Range(ii);
    azi_r=deg2rad(acoustic_bearing);
    stw=Interp.NAV_SPEED(ii)+.1;
    hdg_r=deg2rad(90-Interp.NAV_HEADING(ii));
    
    
    mu_t=[range*cos(azi_r)*(exp(-1*var_Ra_r)-exp(-.5*var_Ra_r));stw*cos(hdg_r)*(exp(-1*var_Ra1_r)-exp(-.5*var_Ra1_r));range*sin(azi_r)*(exp(-1*var_Ra_r)-exp(-.5*var_Ra_r));stw*sin(hdg_r)*(exp(-1*var_Ra1_r)-exp(-.5*var_Ra1_r))];
    
    R(1,1)=(range^2*exp(-2*var_Ra_r)*((cos(azi_r)^2)*(cosh(2*var_Ra_r)-cosh(var_Ra_r))+(sin(azi_r)^2*(sinh(2*var_Ra_r)-sinh(var_Ra_r)))))+(var_Rr_r*exp(-2*var_Ra_r)*((cos(azi_r)^2)*(2*cosh(2*var_Ra_r)-cosh(var_Ra_r))+(sin(azi_r)^2*(2*sinh(2*var_Ra_r)-sinh(var_Ra_r)))));
    R(2,2)=(stw^2*exp(-2*var_Ra1_r)*((cos(hdg_r)^2)*(cosh(2*var_Ra1_r)-cosh(var_Ra1_r))+(sin(hdg_r)^2*(sinh(2*var_Ra1_r)-sinh(var_Ra1_r)))))+(var_Rs_r*exp(-2*var_Ra1_r)*((cos(hdg_r)^2)*(2*cosh(2*var_Ra1_r)-cosh(var_Ra1_r))+(sin(hdg_r)^2*(2*sinh(2*var_Ra1_r)-sinh(var_Ra1_r)))));
    R(3,3)=(range^2*exp(-2*var_Ra_r)*((sin(azi_r)^2)*(cosh(2*var_Ra_r)-cosh(var_Ra_r))+(cos(azi_r)^2*(sinh(2*var_Ra_r)-sinh(var_Ra_r)))))+(var_Rr_r*exp(-2*var_Ra_r)*((sin(azi_r)^2)*(2*cosh(2*var_Ra_r)-cosh(var_Ra_r))+(cos(azi_r)^2*(2*sinh(2*var_Ra_r)-sinh(var_Ra_r)))));
    R(4,4)=(stw^2*exp(-2*var_Ra1_r)*((sin(hdg_r)^2)*(cosh(2*var_Ra1_r)-cosh(var_Ra1_r))+(cos(hdg_r)^2*(sinh(2*var_Ra1_r)-sinh(var_Ra1_r)))))+(var_Rs_r*exp(-2*var_Ra1_r)*((sin(hdg_r)^2)*(2*cosh(2*var_Ra1_r)-cosh(var_Ra1_r))+(cos(hdg_r)^2*(2*sinh(2*var_Ra1_r)-sinh(var_Ra1_r)))));

    R(1,3)=sin(azi_r)*cos(azi_r)*exp(-4*var_Ra_r)*(var_Rr_r+(range^2+var_Rr_r)*(1-exp(var_Ra_r)));
    R(3,1)=R(1,3);
    
    R(2,4)=sin(hdg_r)*cos(hdg_r)*exp(-4*var_Ra1_r)*(var_Rs_r+(stw^2+var_Ra1_r)*(1-exp(var_Ra1_r)));
    R(4,2)=R(2,4);
    
    z_k=[Interp.e_gps(ii)-Interp.Range(ii)*cosd(acoustic_bearing);stw*cos(hdg_r);Interp.n_gps(ii)-Interp.Range(ii)*sind(acoustic_bearing);stw*sin(hdg_r)]-mu_t;
    z_k_out(:,ii)=z_k;

    %Calculate innovation
    r_k=z_k-H*x_k_minus;

    %Calculate innovation covariance
    S=H*P_minus*H.'+R;
    S_out(:,:,ii)=S;
    
    %Update Kalman Gain after estimate vector calculation
    K=(P_minus*H.')/S;
    K_out(:,:,ii)=K;

    %Update state vector
    x_k_plus=x_k_minus+K*r_k;

    %Update error covariance matrix with new Kalman Gain
    %Joseph stabilized equation
    P_plus=(eye(6)-K*H)*P_minus*(eye(6)-K*H)'+K*R*K';
    
    %Calculate the normalized innovation squared (NIS)
    epsilon_v(ii)=r_k.'*inv(S)*r_k;
        
    data(7:12,ii)=x_k_plus;
    data(13,ii)=hypot(x_k_plus(2,1),x_k_plus(4,1));
    data(14,ii)=atan2d(x_k_plus(4,1),x_k_plus(2,1));
    data(15,ii)=norm(P_plus);
    data(16:19,ii)=r_k;
end


sum_kj=zeros(length(r_k),1);
sum_kk=zeros(length(r_k),1);
sum_jj=zeros(length(r_k),1);
for jj=1:steps-1
    sum_kj(1)=sum_kj(1)+(data(16,jj)*data(16,jj+1));
    sum_kj(2)=sum_kj(2)+(data(17,jj)*data(17,jj+1));
    sum_kj(3)=sum_kj(3)+(data(18,jj)*data(18,jj+1));
    sum_kj(4)=sum_kj(4)+(data(19,jj)*data(19,jj+1));
    sum_kk(1)=sum_kk(1)+(data(16,jj))^2;
    sum_kk(2)=sum_kk(2)+(data(17,jj))^2;
    sum_kk(3)=sum_kk(3)+(data(18,jj))^2;
    sum_kk(4)=sum_kk(4)+(data(19,jj))^2;
    sum_jj(1)=sum_jj(1)+(data(16,jj+1))^2;
    sum_jj(2)=sum_jj(2)+(data(17,jj+1))^2;
    sum_jj(3)=sum_jj(3)+(data(18,jj+1))^2;
    sum_jj(4)=sum_jj(4)+(data(19,jj+1))^2;
end
rho_bar=zeros(4,1);
rho_bar(1,1)=sum_kj(1)/sqrt(sum_kk(1)*sum_jj(1));
rho_bar(2,1)=sum_kj(2)/sqrt(sum_kk(2)*sum_jj(2));
rho_bar(3,1)=sum_kj(3)/sqrt(sum_kk(3)*sum_jj(3));
rho_bar(4,1)=sum_kj(4)/sqrt(sum_kk(4)*sum_jj(4));

end