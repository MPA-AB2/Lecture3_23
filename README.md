# Lecture3 - KEYPOINT DETECTION AND MATCHING

[**Benchmark Results**](https://moodle.vut.cz/pluginfile.php/405592/mod_resource/content/1/BenchmarkPanorama.xlsx%20-%20List1.pdf)

## Preparation

1. Run Git bash.
2. Set username by: `$ git config --global user.name "name_of_your_GitHub_profile"`
3. Set email by: `$ git config --global user.email "email@example.com"`
4. Select some MAIN folder with write permision.
5. Clone the **Lecture3** repository from GitHub by: `$ git clone https://github.com/MPC-AB2/Lecture3.git`
6. In the MAIN folder should be new folder **Lecture3**.
7. In the **Lecture3** folder create subfolder **NAME_OF_YOUR_TEAM**.
8. Run Git bash in **Lecture3** folder (should be *main* branch active).
9. Create a new branch for your team by: `$ git checkout -b NAME_OF_YOUR_TEAM`
10. Check that  *NAME_OF_YOUR_TEAM* branch is active.
11. Continue to the task...


## Tasks to do

1. Download the data in a zip folder from [here](https://www.vut.cz/www_base/vutdisk.php?i=285045ae6a). Extract the content of the zip folder into **Lecture3** folder. The zip folder contains a set of splitted aerial images of BUT Campus *image_splitted.mat*, an encrypted ground truht image *evaluatePanorama.mat* for MATLAB and the initialization of panorama (*panorama.png*). The task for this exercise will be to implement an algorithm for stitching of particular splitted images into one panoramic image which will corresponds to the original one. 
2. Apply some point-detection method(s) and detect interesting points from images from the dataset. Create (extract) local descriptors to each detected feature point. Display the detected feature points for the initial panoramic image (with the black background) and surrounding image in the dataset. Explore where the feature points are detected in both images and look if there is some overlapping area. Apply any of the feature-matching algorithms to stitch those two images (initial panoramic and an arbitrary surrounding image) based on extracted local features. Explore the result. Make sure the algorithms you have chosen provide precise results and the overlapping areas are properly fused.
3. Design an automatic algorithm for stitching of the remaining image parts. All images have to be connected to the previous fused image (with the black background). Make sure that the design algorithm will be universal. Order of images in the dataset can be randomly changed.
4. Use the provided MATLAB function for evaluation of the stitching result and submit the output into the shared table. The function evalPanorama.p called as:
`[PIQE,mError] = evalPanorama(panorama)`,
has the following inputs and outputs:
  * panorama - variable with initial panoramic image (provided) including stitched patches (RGB, uint8, the size of the image must be the same!)
  * PIQE - evaluation criterion of image quality (lower values, better result)
  * mError - mean error between your panoramic output image and ground truth image
5. Calculate above-mentioned evaluation criteria. Save one **TIFF** image showing the best achieved results of panorama and store your implemented algorithm as a form of function `[output_panorama] = TeamName( J, init_panorama)`. The function will be used for evaluation of universality of your solution using another input image. **Push** your program implementations into GitHub repository **Lecture3** using the **branch of your team** (stage changed -> fill commit message -> sign off -> commit -> push -> select *NAME_OF_YOUR_TEAM* branch -> push -> manager-core -> web browser -> fill your credentials).
6. Submit the best-obtained result of your method evaluated on the competition dataset using the evaluation function (i.e. submit the calculated evaluation values) into a shared [Excel table](https://docs.google.com/spreadsheets/d/1fmzAsSK1YGJnBL6uskm5JQJ0MVPwZV8D/edit?usp=sharing&ouid=105272487043795807825&rtpof=true&sd=true). The evaluation of results from each team will be presented at the end of the lecture.
