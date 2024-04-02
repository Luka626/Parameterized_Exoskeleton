b= 13
a= 8
LA_length = 230

% WRITE TEXT FILE
fileID = fopen('C:\MCG4322B\MCG4322B\analysis\test_print.txt','w');
formatSpec = '"height" = %3.1f \n "width" = %3.1f \n "length" = %3.1f';
fprintf(fileID,formatSpec,b, a, LA_length);