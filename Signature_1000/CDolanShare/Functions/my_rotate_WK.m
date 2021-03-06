function [ur,vr,thetad]=my_rotate(u,v,thetad)
%function [ur,[vr],thetad]=rotate(u,[v])
%           Rotates into direction of maximum variance if no theta
%           specified, if theta srotate sin to that direction
%     u is vector velocity, ur is rotated vector velocity
%      direction of theta is counterclockwise, based on E vel 1st, N vel second
if nargin==1;
    v=imagg(u);
    u=real(u);
    maxvar=1;
    
end
if nargin==2;
    maxvar=1;
    
end
if nargin==3;
    maxvar=0;
end
if 0
if any( isnan(u(:)))|(isnan(v(:)) )
    disp('NaNs found')
    ur=oness(u)*nan;
    vr=ur;
    g=find( (~isnan(u(:)))&(~isnan(v(:))) );
    if length(g)>1;
        u=u(g);
        v=v(g);
    end
else
    ur=u;
    vr=u;
    g=1:length(u(:));
end
end
if maxvar
    if 1 %length(g)>1
%         PT: for variance (waves)        
%         cv=cov([u(:), v(:)]);
%         theta=0.5*atan2(2.*cv(2,1),(cv(1,1)-cv(2,2)) );
%         thetad=theta*180./pi;
%         WK: for currents, quick version
          theta = atan2 (nansum(v(:)) , nansum(u(:)));
          thetad = theta*180./pi;
        
    else;
        thetad=nan;
    end
end

vr=-u.*sind(thetad)+v.*cosd(thetad);
ur=u.*cosd(thetad)+v.*sind(thetad);

if nargin==1
    ur=ur+sqrt(-1)*vr;
    vr=thetad;
    thetad=[];
end

