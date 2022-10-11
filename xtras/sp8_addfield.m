function s = sp8_addfield(s,fieldname,fieldvalues)
%SP8_ADDFIELD Adds a field to a given structure
%   
%   s = SP8_ADDFIELD(s,fieldname,fieldvalues) adds the values in
%   'fieldvalues' to a new field 's.fieldname'
%   'fieldvalues' should be a cell array with the number of entries equal
%   to '1' or the length of the structure s
%
%
%   Jules Dake
%   Uni Ulm, 9 Oct 2014
%   
if length(fieldvalues) == 1
    for I=1:length(s)
        s(I).temp = fieldvalues{1};
    end
    s = sp8_renameStructField(s,'temp',fieldname);
    
elseif length(s) == length(fieldvalues)
    for I=1:length(s)
        s(I).temp = fieldvalues{I};
    end
    s = sp8_renameStructField(s,'temp',fieldname);
    
else
    error('Dimension mismatch, check length of fieldvalues')
end


end

