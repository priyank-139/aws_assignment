# Assignment -3 host static website using S3 and cloud front 

## prerequsites 

```
1- Aws account 

2- aws cli tool 

```

## steps 

```
1- clone repo  git clone  https://github.com/OT-TRAINING/DeploymentStrategies

2- create s3 bucket in may case bucket name is opstree-task-3

3- create create s3 bucket policy to PublicReadGetObject add to permission section in opstree-task-3 bucket
 
4- go to bucket properties > Static website hosting  | enable Static website hosting

3- Now, from shell where cloned the above repo  

```
cd DeploymentStrategies/html/leadmark/public_html/

```

4- copy assets and index.html to s3 bucket name opstree-task-3  using aws cli command 

 ```
 aws s3 cp index.html s3://mybucket/index.html
 
 ```
 
 ## cloud front website hosting 
 
 ```
 
1- go to cloud front service > create disribution

2- In the origin domain select s3 bucket dns that was already created from origin domain drop down menu

3-  once cloud front dns created hit the the dns static website will be hosted

```


## outputs 


<img src=./snaps/1.png>


<img src=./snaps/2.png>


<img src=./snaps/3.png>


<img src=./snaps/4.png>


<img src=./snaps/5.png>


<img src=./snaps/6.png>

<img src=./snaps/7.png>

<img src=./snaps/8.png>
