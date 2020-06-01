clc;
clear all;
N=1.6;
x=ones(8,1)*0.75;
syms z;
channel=1-z^{-1};

%z-transfrom of input sequence
z_x=0;
syms z;
for i=1:length(x)
    z_x=z_x+x(i)*z^{1-i};
end

%multiply by channel
z_output=z_x*channel;
%inverse z transform
o=iztrans(z_output);
%convert into seqeunce
output_without_precoder=delta2sequence(o,length(x));

%THP
channel_inverse=1/channel;
%multiply by channel inverse
z_pre_equalised=z_x*channel_inverse;
%inverse z trans
o=iztrans(z_pre_equalised);
pre_equalised=delta2sequence(o,length(x));
%modulo to avoid divergent
pre_equalised_with_mod=modulo(pre_equalised,N);

%z-transform of pre_equalised seqence
zz_pre_equalised=0;
for i=1:length(x)
    syms z;
    zz_pre_equalised=zz_pre_equalised+pre_equalised_with_mod(i)*z^{1-i};
end
%passing through channel
z_output=zz_pre_equalised*channel;
%inverse z transform
o=iztrans(z_output);
output=delta2sequence(o,length(x));
%final modulo
output_with_mod=modulo(output,N);

%plot
n=[0:length(x)-1];
figure
stem(n,[x, output_without_precoder]);
title('Transmitted and Received Sequence'); 
xlabel('n');
legend({'transmitted sequence','received sequence'},'Location','northwest')
saveas(gcf,'pic/original.png');

figure
stem(n,[x, pre_equalised]);
title('Transmitted Sequence without Modulo'); 
xlabel('n');
legend({'original sequence','transmitted sequence without modulo'},'Location','northwest')
saveas(gcf,'pic/pre_eq_without_mod.png');

figure
stem(n,[x, pre_equalised_with_mod]);
title('Transmitted Sequence with Modulo'); 
xlabel('n');
legend({'original sequence','transmitted sequence with modulo'},'Location','southwest')
saveas(gcf,'pic/pre_eq_with_mod.png');

figure
stem(n,[x,output]);
title('Received Sequence without Modulo'); 
xlabel('n');
legend({'original sequence','received sequence without modulo'},'Location','southwest')
saveas(gcf,'pic/out_without_mod.png');

figure
stem(n,[x,output_with_mod]);
title('Received Sequence with Modulo'); 
xlabel('n');
legend({'original sequence','received sequence with modulo'},'Location','southwest')
saveas(gcf,'pic/out_with_mod.png');

function mod=modulo(sequence,N)
    for i=1:length(sequence)
        while(sequence(i)>N/2)
            sequence(i)=sequence(i)-N;
        end
        while(sequence(i)<-N/2)
            sequence(i)=sequence(i)+N;
        end
    end
    mod=sequence;
end

function s=delta2sequence(expression,len)
    s=zeros(len,1);
    for i=0:len-1
        syms n;
        s(i+1)=double(subs(expression,n,i));
    end
end