% figure
% plot(Data.Burst_Time,Data.Burst_VelBeam1(:,3),Data.Burst_Time,Data.Burst_VelBeam2(:,3),Data.Burst_Time,Data.Burst_VelBeam3(:,3),Data.Burst_Time,Data.Burst_VelBeam4(:,4))
% figure
% plot(Data.BottomTrack_Time_UNIX,Data.BottomTrack_VelBeam1,Data.BottomTrack_Time_UNIX,Data.BottomTrack_VelBeam2,Data.BottomTrack_Time_UNIX,Data.BottomTrack_VelBeam3,Data.BottomTrack_Time_UNIX,Data.BottomTrack_VelBeam4)
% figure
% plot(Data.BottomTrack_Time,Data.Burst_VelBeam4_Interp(:,3)-Data.BottomTrack_VelBeam4)
% beam_mag=sqrt(Data.Comp_VelBeam1.^2 + Data.Comp_VelBeam2.^2 + Data.Comp_VelBeam3.^2 + Data.Comp_VelBeam4.^2);
% figure
% plot(beam_mag(:,3))
% figure
% plot(Data.( [ dataModeWord '_VelNorth' ] )(:,3))
% figure
% plot(Data.( [ dataModeWord '_VelEast' ] )(:,3))
% figure
% plot(movmean(avg_mag,20))

% jetyak_time=zeros(length(GPS),1);
% for ii=1:length(GPS)
%     jetyak_time(ii)=315964782+((GPS(ii,5)*7*86400)+(GPS(ii,4)*.001));
% end

% ind =1;
% while GPS(ind,3)<3
%     ind=ind+1;
% end
% GPS_trimmed=GPS(ind:end,:);

% g=[1;2;3;4];
% G=g*g.';

% delta_p=zeros(1,length(SOURCEXY.TIME)-1);
% for jj=2:length(SOURCEXY.TIME)
%     delta_p(jj-1)=sqrt(((SOURCEXY.ACOUSTIC_SOURCE_X(jj)-SOURCEXY.ACOUSTIC_SOURCE_X(jj-1))^2+(SOURCEXY.ACOUSTIC_SOURCE_Y(jj)-SOURCEXY.ACOUSTIC_SOURCE_Y(jj-1))^2)/(SOURCEXY.TIME(jj)-SOURCEXY.TIME(jj-1)));
% end
% figure
% plot(delta_p)

% A=[1 2 3;nan 4 5;nan 6 nan];
% out = A(all(~isnan(A),2),:); % for nan - rows
% out   %returns the only nan-free row of A: [1 2 3]

% heading_interp=interp1(NAVDR.TIME,NAVDR.NAV_HEADING,ACOUSTICRB.TIME);
% acoustic_true=heading_interp+ACOUSTICRB.ACOUSTIC_BEARING;
% for mm=1:length(acoustic_true)
%     if acoustic_true(mm) >= 360
%         acoustic_true(mm)=acoustic_true(mm)-360;
%     end
% end
% 
% acoustic_pos=zeros(length(acoustic_true),2);
% for nn=1:length(acoustic_true)
%     acoustic_pos(nn,1)=ACOUSTICRB.ACOUSTIC_RANGE(nn)*sind(acoustic_true(nn));
%     acoustic_pos(nn,2)=ACOUSTICRB.ACOUSTIC_RANGE(nn)*cosd(acoustic_true(nn));
% end
% 
% acoustic_pos(:,1)=x_gps_interp-acoustic_pos(:,1);
% acoustic_pos(:,2)=y_gps_interp-acoustic_pos(:,2);
% 
% plot(acoustic_pos(:,1),acoustic_pos(:,2))

