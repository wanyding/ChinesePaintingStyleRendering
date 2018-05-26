Chinese Painting Style Rendering in Real Time
-----------

**Silhousette Detection**
Calculate the dot product of view direction and normal vector in the shading point, then use the user-defined threshold to control the width of the outline.

**Interior Shading**
Utilize the lighting information to do interior colorization. 
t_d=light/* normal
t_w is sampled from a pre-prepared texture 
t_dw=clamp(t_d+t_w-1)
after obtaining the t_dw, I used a guassian blur function to blend five color controled by t_dw.

**Atomosphere Parameter**
the further the model is from camera, the lighter color it will have. 
t_a=1-2^(-distance/scale)
distance is the distance between camera and shading point, scale is a user controled parameter.
Rendering result is presented below:
![image](http://github.com/Britjeans/ChinesePaintingStyleRendering/raw/master/images/depth.jpg)

**NPR Water**
Copy the uv of the original model and flip it. Set the color of the reflection by its height.
![image](http://github.com/Britjeans/ChinesePaintingStyleRendering/raw/master/images/reflection.jpg)

Rendering results
![image](http://github.com/Britjeans/ChinesePaintingStyleRendering/raw/master/images/captured.jpg)
