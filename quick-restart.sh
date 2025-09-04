 #!/bin/bash
 echo "Listing Docker Containers"
 echo "$0"
 echo ""
 sudo docker ps
 echo ""
 echo "Shutting Docker Containers"
 echo ""
 sudo docker compose --profile $1 down
 echo ""
 echo "Pruning Docker Environment"
 echo ""
 sudo docker system prune -a
 y
 echo ""
 echo "Spinning Containers Back Up"
 echo ""
 sudo docker compose --profile $1 up -d
 echo ""
 echo "Done"
 
