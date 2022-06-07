%% TP Imagerie 3D Faure/Sabir

%% Projection de Franges (stéréo-vision active):

clc, clear, close all;
%% II. Projection des franges sur l'objet à reconstruire:

p=20;
theta=30;

fr = double(imread('images/frange1.png'))/255;
fr2 = double(imread('images/frange2.png'))/255;
fr3 = double(imread('images/frange3.png'))/255;
fr4 = double(imread('images/frange4.png'))/255;

im = double(imread('images/objet1.png'))/255;
im2 = double(imread('images/objet2.png'))/255;
im3 = double(imread('images/objet3.png'))/255;
im4 = double(imread('images/objet4.png'))/255;

im = imrotate(im, 90);
im = im(612:1295,2:600);

im2 = imrotate(im2, 90);
im2 = im2(612:1295,2:600);

im3 = imrotate(im3, 90);
im3 = im3(612:1295,2:600);

im4 = imrotate(im4, 90);
im4 = im4(612:1295,2:600);


fr = imrotate(fr, 90);
fr = fr(612:1295,2:600);

fr2 = imrotate(fr2, 90);
fr2 = fr2(612:1295,2:600);

fr3 = imrotate(fr3, 90);
fr3 = fr3(612:1295,2:600);

fr4 = imrotate(fr4, 90);
fr4 = fr4(612:1295,2:600);


im_obj(:,:,1) = im;
im_obj(:,:,2) = im2;
im_obj(:,:,3) = im3;
im_obj(:,:,4) = im4;

im_ref(:,:,1) = fr;
im_ref(:,:,2) = fr2;
im_ref(:,:,3) = fr3;
im_ref(:,:,4) = fr4;

figure();
for n=1:4
    subplot(2,2,n);imshow(im_obj(:,:,n),[]);colorbar;axis on;title(sprintf('image %d crop objet',n))
end

figure();
for n=1:4
    subplot(2,2,n);imshow(im_ref(:,:,n),[]);colorbar;axis on;title(sprintf('image %d crop sans objet',n))
end


%%
%% III. Calcul de carte de déphasage du plan de réference et de l'objet:
%% III.1 Calcul du numérateur et du dénominateur de tan(ph_WrapObj):
Num=0; Denum=0;
for n=1:4
    Num= Num + im_obj(:,:,n).*sin((2*pi*(n-1))/4);
    Denum= Denum + im_obj(:,:,n).*cos((2*pi*(n-1))/4);
end
%% III.2 Phase Enroulée image avec objet:
    
ph_WrapObj= atan2(Num,Denum);
figure(); 
imagesc(ph_WrapObj); axis on, axis on;  colorbar, title('Phase Enroulée objet'); 
%% III.2 Phase Enroulée image sans objet:
Num1=0; Denum1=0;
for n=1:4
    Num1= Num1 + im_ref(:,:,n).*sin((2*pi*(n-1))/4);
    Denum1= Denum1 + im_ref(:,:,n).*cos((2*pi*(n-1))/4);
end
ph_WrapRef= atan2(Num1,Denum1);
figure(); 
imagesc(ph_WrapRef); axis on, axis on; colorbar, title('Phase Enroulée Image de reference');
%% IV Déroulement de phase

ph_unwrapRef = phase_unwrap_Ghiglia(ph_WrapRef);
ph_unwrapObj = phase_unwrap_Ghiglia(ph_WrapObj);
figure();
subplot(1,2,1); 
imagesc(ph_unwrapRef); axis on, axis on; colorbar, title('Phase unwrap Ref Ghiglia');
subplot(1,2,2); 
imagesc(ph_unwrapObj); axis on, axis on; colorbar, title('Phase unwrap Obj Ghiglia');
%% Unwrap Matlab
ph_unwrapRef1 = unwrap(ph_WrapRef,1);
ph_unwrapObj1 = unwrap(ph_WrapObj,1);
figure();
subplot(1,2,1); 
imagesc(ph_unwrapRef1); axis on, axis on; colorbar, title('Phase unwrap Ref MATLAB');
subplot(1,2,2); 
imagesc(ph_unwrapObj1); axis on, axis on; colorbar, title('Phase unwrap Obj MATLAB');
%% Carte de profondeur
S_phi = ph_unwrapObj - ph_unwrapRef; % Avec Ghiglia
figure();
subplot(1,2,1);
imagesc(S_phi); axis on; colorbar, title('Dephasage objet avec Ghiglia');

S_phi1 = ph_unwrapObj1 - ph_unwrapRef1; % Avec Unwrap de Matlab
subplot(1,2,2);
imagesc(S_phi1); axis on; colorbar, title('Dephasage objet avec Unwrap');

Z_recon1= (S_phi1*p)/2*pi*tand(theta);
figure();
imagesc(Z_recon1);title('Reconstruction de la prondeur avec unwrap');colorbar, axis equal, axis on;

Z_recon= (S_phi*p)/2*pi*tand(theta);
figure();
imagesc(Z_recon);title('Reconstruction de la prondeur avec Ghiglia');colorbar, axis equal, axis on;

%% Estimation de Z

figure();
imshow(Z_recon,[]);colorbar;title('estimation de z');