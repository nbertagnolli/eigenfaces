%Nicolas Bertagnolli

%Script to Perform Facial Recognition and Classification
clc;
clear;

%%Train Data and Initialize 
%directory = uigetdir;
directory = 'C:\Users\tetracycline\Documents\MATLAB\Playthings\EigenfaceProject\Recognition\Happy';
[eigenface_system, face_system,mean_face,rows,columns,num_faces,files,directory]...
    = generateFaceSpace(directory,'*.sad');

eigenface_system = eigenface_system(:,1:num_faces);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Facial Classification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in File
[FileName,PathName] = uigetfile('*.*');
picture = imread(strcat(PathName,FileName));


%%%%%%
%Uhhh.. is RGB need Grey scale willl fix later...
picture = picture(:,:,1);
%%%%%

%Vectorize and resize image
original_picture = double(imresize(picture,[rows,columns]));
diff_picture = double(original_picture(:))-mean_face;


%dot picture with all eigenfaces projecting it into face space
picture_weights  = diff_picture'*eigenface_system;

%Recompose original image using the weights from the eigenface projection
recomposed_picture = eigenface_system * picture_weights'+mean_face;

%Examine the difference between the original image and the recomposed
%image.
error = (recomposed_picture-(diff_picture+mean_face))'*(recomposed_picture-(diff_picture+mean_face));

if(error < 1000)
    disp('This is a face')
else
    disp('not a face')
end

tempImage = vectorToImage(recomposed_picture,rows,columns,0);
imshow(uint8(tempImage));
figure()
imshow(uint8(original_picture))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Facial Recognition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in the unkown face and subtract off the mean
[FileName,PathName] = uigetfile('*.*');
newUnkFace = imread(strcat(PathName,FileName));
unkFace = imresize(newUnkFace,[rows,columns]);
%deal with RGB BULLSHIT
diffUnkFace = double(unkFace(:))-mean_face;

%Normalize the vector that is the unknown face so that it is in the same
%normalized space as eigenvectors.
%normalizer = sqrt(diffUnkFace'*diffUnkFace);
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%Don't normalize it be bad...
diff_unkown_face = diffUnkFace; %/normalizer;

%Now construct an Omega for the unkown image.  This omega represents a
%weighting of the eigenfaces

%!!!Could have issues with degeneracy using handles.files insted of rank
%but for now not going to worry about it.

%Basically it takes the dot product of each column of U (Which is the Eigenvector)
%Representation of the Covariance matrix in PCA with the vector of the
%unkown face.  This forms an "Omega" which represents the weighting of each
%vector in composing the new face.  If this doesn't make sense think of
%each entry in unkOmega as representing a scalar to be multiplied by the
%associated eigenvector in U and then summed together to get the unkown
%face?  I can explain better in person.
unkOmega = [];
for k = 1:num_faces
   unkOmega = [unkOmega, eigenface_system(:,k)'*diff_unkown_face];
end
unkOmega = unkOmega';

%Now construct an Omega for each of the images in our starting set.  These
%will be used to minimize the Euclidian distance and find the results.

trainOmega = [];
for k = 1:num_faces
    Omega = [];
    tempface = imread(strcat(directory,'\',files(k).name));
    newface = uint8(tempface);
    finalFace = imresize(newface,[rows,columns]);
    faceVector = double(finalFace(:))-mean_face;
    for i = 1:num_faces
        Omega = [Omega, eigenface_system(:,i)'*faceVector];
    end
    Omega = Omega';
    trainOmega = [trainOmega,Omega];
end


%Minimize Euclidean Distance.  Try other norms for possibly better
%performance in later testing.
matchMat = []
for k = 1:num_faces
    diff = unkOmega-trainOmega(:,k);
    temp = sqrt(diff'*diff);
    matchMat = [matchMat,temp];
end

%Find the smallest distance that was calculated
training = find(matchMat == min(matchMat));

%Show the face associated with the minimum distance.
subplot(1,2,1)
imshow(imread(strcat(directory,'\',files(training).name)))
title('Known Face')
subplot(1,2,2)
imshow(newUnkFace)
title('Recognized Face')






%Can display a face from a vectorized face
%temp2 = vectorToImage(face_system(:,1),rows,columns);
tempImage = vectorToImage(mean_face(:,1),rows,columns);
imshow(uint8(tempImage));
tempImage = vectorToImage(eigenface_system(:,3),rows,columns);
imshow(tempImage);