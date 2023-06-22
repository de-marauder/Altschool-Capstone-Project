set -e

docker pull demarauder/zombrary:v1
docker run -itd -p 5000:5000 \
        --network app \
        -e 'DATABASE_URL=mongodb+srv://de-marauder:qhv9qaHFbsF1Bkjp@zombrary.8rod4.mongodb.net/?retryWrites=true&w=majority' \
        --name zombrary \
        demarauder/zombrary
docker run -d -p 5000:5000 \
        --network app \
        -e 'DATABASE_URL=mongodb://root:root@db.de-marauder.me' \
        --name zombrary \
        demarauder/zombrary

