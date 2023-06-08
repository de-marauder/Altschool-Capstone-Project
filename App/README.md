# zombrary

### Save your books and let them never be forgotten.

## Setup
```bash
docker pull demarauder/zombrary:v1
```

```bash
docker run -it --rm -p 5000:5000 \
        -e 'DATABASE_URL=mongodb+srv://de-marauder:<password>@zombrary.8rod4.mongodb.net/?retryWrites=true&w=majority' \
        --name zombrary \
        demarauder/zombrary:v1

```