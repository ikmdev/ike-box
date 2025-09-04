 #!/bin/bash
 echo "Listing Docker Containers"
 echo ""
 sudo docker ps
 echo ""
 echo "Shutting Docker Containers"
 echo ""
 sudo docker compose --profile $0 down
 echo ""
 echo "Pruning Docker Environment"
 echo ""
 sudo docker system prune -a
 echo ""
 echo "Spinning Containers Back Up"
 echo ""
 sudo docker compose --profile $0 up -d
 echo ""
 echo "Done"
 
