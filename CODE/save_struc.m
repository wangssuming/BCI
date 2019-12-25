
A(end+1).Name = 'S1_M1_ICMS_2'
A(end).Trajectory = [];
A(end).Velocity = [];
A(end).Velocity_X = [];
A(end).Velocity_Y = [];
A(end).Acceleration = [];
A(end).Acceleration_X = [];
A(end).Acceleration_Y = [];

for t = 1:length(fieldnames(Acceleration_velocity.Trajectory))
    Trial = sprintf('Trial_%d',t);
    A(end).Trajectory = [A(end).Trajectory;num2cell(Acceleration_velocity.Trajectory.(Trial),1)];
end
A(end).Velocity = [A(end).Velocity;Acceleration_velocity.Velocity];
A(end).Velocity_X = [A(end).Velocity_X;Acceleration_velocity.Velocity_X];
A(end).Velocity_Y = [A(end).Velocity_Y;Acceleration_velocity.Velocity_Y];
A(end).Acceleration = [A(end).Acceleration;Acceleration_velocity.Acceleration.acceleration];
A(end).Acceleration_X = [A(end).Acceleration_X;Acceleration_velocity.Acceleration.acceleration_X];
A(end).Acceleration_Y = [A(end).Acceleration_Y;Acceleration_velocity.Acceleration.acceleration_Y];

mkdir(fullfile('D:\Seneory_Feedback\all_Tra_Acce_Vel'));
Write = fullfile('D:\Seneory_Feedback\all_Tra_Acce_Vel');
save(fullfile(Write,'A'),'A','-v7.3');