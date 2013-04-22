function [jpeaks,jvalleys,heights,spans] = peak_find(data)
% function [jpeaks,jvalleys,heights,spans] = peak_find(data)

npt = length(data);
greater_than_left = data(2:npt-1) > data(1:npt-2);
greater_than_right = data(2:npt-1) > data(3:npt);
jpeaks = 1+find(greater_than_left & greater_than_right);

less_than_left = data(2:npt-1) < data(1:npt-2);
less_than_right = data(2:npt-1) < data(3:npt);
jvalleys = 1+find(less_than_left & less_than_right);
if(jpeaks(1)<jvalleys(1))
    [~,new_valley] = min(data(1:jpeaks(1)));
    jvalleys = [ new_valley jvalleys];
end
if(jpeaks(end)>jvalleys(end))
    [~,new_valley] = min(data(jpeaks(end):end));
    new_valley = new_valley + jpeaks(end)-1;
    jvalleys = [ jvalleys new_valley];
end

if(numel(jpeaks)+1 ~= numel(jvalleys))
    error('Need one more valley than peaks!')
end

left_heights = data(jpeaks) - data(jvalleys(1:end-1));
right_heights = data(jpeaks) - data(jvalleys(2:end));
heights = max(left_heights,right_heights);
spans = jvalleys(2:end) - jvalleys(1:end-1);

end