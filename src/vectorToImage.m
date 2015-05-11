%This function takes a vectorized image and displays it
%
%
%%Parameters
%
%+face_vector - A facial vector can be any type
%+rows - the number of rows in the original image
%+columns - the number of columns in the original image
%+adjust - wheather you want the image formatted to a special range
%
%%Returns
%+final_image - the rows x columns image

function final_image = vectorToImage(face_vector,rows,columns,adjust)

final_image = [];
idx_current = 1; 
idx_next = rows;
for i = 1:columns
    final_image = [final_image, face_vector(idx_current:idx_next)];
    idx_current = idx_current + rows;
    idx_next = idx_next + rows;   
end

if(adjust)
    final_image = imadjust(final_image,stretchlim(final_image,[0.0001 0.9999]))
end