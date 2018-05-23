function str = num2words_fast(num)
% Fast conversion of a number to a string with the English name of the number value.
%
% (c) 2016 Stephen Cobeldick
%
% The function "num2words" has many useful formatting options but some users
% may prefer a faster conversion: "num2words_fast" runs around twice as fast.
%
% Syntax:
%  str = num2words_fast(num)
%
% The number format is based on: http://www.blackwasp.co.uk/NumberToWords.aspx
% Floating-point values are rounded, and to provide the least-unexpected
% output significant figures are internally limited to 6 or 15 digits (for
% single and double respectively). Integer classes parse at full precision.
%
% See also NUM2WORDS NUM2MYRIAD NUM2ORDINAL WORDS2NUM NUM2STR NATSORT NUM2SIP SIP2NUM NUM2BIP BIP2NUM CELLFUN INTMAX TTS
%
% ### Examples ###
%
% num2words_fast(0)
%  ans = 'Zero'
%
% num2words_fast(1024)
%  ans = 'One Thousand and Twenty-Four'
% num2words_fast(-1024)
%  ans = 'Negative One Thousand and Twenty-Four'
%
% num2words_fast(1e23)
%  ans = 'One Hundred Sextillion'
% num2words_fast(1.23e308)
%  ans = 'One Hundred and Twenty-Three Uncentillion'
%
% num2words_fast(Inf)
%  ans = 'Infinity'
% num2words_fast(NaN)
%  ans = 'Not-a-Number'
%
% ### Input and Output Arguments ###
%
% Input:
%  num = Scalar Numeric, the value to be converted to English words / number name.
%
% Output:
%  str = String, with number name of the value of <num>, written in short scale.
%
% str = num2words_fast(num)

assert(isnumeric(num)&&isscalar(num),'First input <num> must be a numeric scalar')
assert(isreal(num),'First input <num> cannot be a complex value: %g%+gi',num,imag(num))
%
if isfloat(num)
	dgt = 6+9*isa(num,'double');
	raw = sprintf('%#+.*e', dgt-1, round(num));
	if strcmp(raw,'NaN')%||strcmp(raw(2:end),'NaN')
		str = 'Not-a-Number';
	elseif strcmp(raw(2:end),'Inf')
		str = 'Infinity';
	else % scientific notation to vector
		idx = strfind(raw,'e');
		pwr = sscanf(raw(idx:end),'e%d');
		str = n2wfParse(raw([2,4:idx-1])-48,pwr);
	end
else % int | uint
	cls = class(num);
	bit = sscanf(cls, '%*[ui]nt%u');
	pfx = {[],[],'%h','%h','%','%l'}; % {2,4,8,16,32,64} bit
	raw = sprintf([pfx{log2(bit)},cls(1)],num);
	pwr = numel(raw)-1-(num<0);
	str = n2wfParse(raw(1+(num<0):end)-48,pwr);
	%
end
%
if strncmp(raw,'-',1)
	str = sprintf('Negative %s',str);
end
%
end
%----------------------------------------------------------------------END:num2words_fast
function str = n2wfParse(vec,pwr)
%
if ~any(vec)
	str = 'Zero';
	return
end
%
rdo = pwr-(0:numel(vec)-1);
grp = rem(rdo,3);
% Reshape into 3*N array, each column is one group:
mat = reshape([zeros(1,2-grp(1)),vec(rdo>=0),zeros(1,grp(end))],3,[]);
idy = any(mat,1);
mat = mat(:,idy);
% Move teens into ones:
idE = mat(2,:)==1;
mat(3,idE) = mat(3,idE) + 10;
mat(2,idE) = 0;
%
mlt = floor(pwr/3)-(0:numel(idy));
mlt = mlt(idy);
% Indices for digits, ',' and 'and':
idH = mat(1,:)>0;
idT = mat(2,:)>0;
idO = mat(3,:)>0;
idC = idH | mlt>0 | nnz(idy)==1;
idA = idH&(idT|idO) | ~idC;
% Indices for multipliers:
idS = mlt>=2;
idM = mlt==1;
%
StT = {[],'Twenty','Thirty','Forty','Fifty','Sixty','Seventy','Eighty','Ninety'};
StO = {'One','Two','Three','Four','Five','Six','Seven','Eight','Nine','Ten','Eleven','Twelve','Thirteen','Fourteen','Fifteen','Sixteen','Seventeen','Eighteen','Nineteen'};
StS = {'M','B','Tr','Quadr','Quint','Sext','Sept','Oct','Non','Dec','Undec','Duodec','Tredec','Quattuordec','Quindec','Sedec','Septendec','Octodec','Novendec','Vigint','Unvigint','Duovigint','Tresvigint','Quattuorvigint','Quinvigint','Sesvigint','Septemvigint','Octovigint','Novemvigint','Trigint','Untrigint','Duotrigint','Trestrigint','Quattuortrigint','Quintrigint','Sestrigint','Septentrigint','Octotrigint','Noventrigint','Quadragint','Unquadragint','Duoquadragint','Tresquadragint','Quattuorquadragint','Quinquadragint','Sesquadragint','Septenquadragint','Octoquadragint','Novenquadragint','Quinquagint','Unquinquagint','Duoquinquagint','Tresquinquagint','Quattuorquinquagint','Quinquinquagint','Sesquinquagint','Septenquinquagint','Octoquinquagint','Novenquinquagint','Sexagint','Unsexagint','Duosexagint','Tresexagint','Quattuorsexagint','Quinsexagint','Sesexagint','Septensexagint','Octosexagint','Novensexagint','Septuagint','Unseptuagint','Duoseptuagint','Treseptuagint','Quattuorseptuagint','Quinseptuagint','Seseptuagint','Septenseptuagint','Octoseptuagint','Novenseptuagint','Octogint','Unoctogint','Duooctogint','Tresoctogint','Quattuoroctogint','Quinoctogint','Sexoctogint','Septemoctogint','Octooctogint','Novemoctogint','Nonagint','Unnonagint','Duononagint','Trenonagint','Quattuornonagint','Quinnonagint','Senonagint','Septenonagint','Octononagint','Novenonagint','Cent','Uncent'};
%
% Insert words and punctuation into the cell array:
out = cell(10,size(mat,2));
out(:) = {''};
out(1,idC) = {', '};
out(2,idH) = StO(mat(1,idH));
out(3,idH) = {' Hundred'};
out(4,idA) = {' and '};
out(5,idT) = StT(mat(2,idT));
out(6,idO&idT) = {'-'};
out(7,idO) = StO(mat(3,idO));
out(8,idM|idS) = {' '};
out(9,idM) = {'Thousand'};
out(10,idS) = {'illion'};
if any(idS)
	out(9,idS) = StS(mlt(idS)-1);
end
%
% Concatenate into one string:
str = [out{2:end}];
%
end
%----------------------------------------------------------------------END:n2wfParse