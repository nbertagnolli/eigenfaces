
%This function generates an eigensystem for a set of faces using the
%singular value decomposition on a vectorized picture set
%
%
%%Parameters:
%+filetype -(String)-  The filetypes in the directory to be loaded in as faces
%
%Returns:
%+eigenface_system -(Matrix)- the system of eigenvectors of AA' 
%+face_system -(Matrix)- the matrix of vectorized faces.  Each column is a different
% face
%+mean_face -(Vector)- the average face as a vector for the set of training faces.
%+rows -(double)- the height of the pictures
%+columns -(double)- the width of the pictures
%+num_faces -(doube)- number of faces in training set

 
function [eigenface_system, face_system,mean_face,rows,columns,num_faces,files,directory] = generateFaceSpace(directory,filetype)

 

%directory = 'C:\Users\nicolas bertagnollli\Documents\MATLAB\Playthings\EigenfaceProject\Faces\Test1';
files = dir(directory);%Extract the faces
[rows, columns] = size(imread(strcat(directory,'\',files(3).name)));
%g = gcd(picture_width,picture_height);%These next few lines condence the image down to a more manageable size
%aspectRatio = [rows,columns]/g;
rows = ceil(rows/3)
columns = ceil(columns/3)
num_faces = length(files)-2;%subtract 2 because of hidden files on complete load
faces = [];
meanFace = double(zeros(rows,columns));%Predefine a mean face

%Generates the matrix of faces face_system
for k = 3:num_faces+2
    tempface = imread(strcat(directory,'\',files(k).name));
    newface = uint8(tempface);
    finalFace = imresize(newface,[rows,columns]);
%     figure
%     subplot(1,3,1)
%     imshow(newface)
%     subplot(1,3,2)  
%     imshow(uint8(finalFace))
    faceVector = double(finalFace(:));
%     subplot(1,3,3)
%     imshow(uint8(double(finalFace)-meanFace))
    faces = [faces faceVector];
end

face_system = faces;

%Finds the Average face to be subtracted from all others.
meanVec = sum(faces,2)/num_faces;
mean_face = meanVec;

%Subtract off othe mean face from the faces

faces = faces - repmat(meanVec,1,num_faces);


%Generates orthonormal bases Using SVD
[U,S,V] = svd(double(faces));

eigenface_system = U;





