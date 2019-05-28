# Kubernetes Multicontainer

1. Build images local.

   Navigate to the multi-calculator folder and into the calc-frontend folder. Then run:

   ```bash
   docker build -t calcfrontend .
   ```

   Do the same for the backend.

1) Push the images to your ACR.

   - Login to your ACR

     ```bash
     docker login YOURREGISTRY.io
     ```

     Provide username and password as found in the portal.

   - Tag your image

     ```bash
     docker tag calcfrontend YOURREGISTRY.io/calcfrontend
     ```

   - Then push your images. Do it for both frontend and backend.

     ```bash
     docker push YOURREGISTRY.io/calcfrontend
     ```

   Your images are now available in your ACR.

1) Run your images by using YAML files. Apply the yaml files using

   ```bash
   kubectl apply -f filename.yml
   ```

To make your application accessible from the internet modify your frontend service accordingly.

```bash
kubectl edit svc/calcfrontend-svc
```
