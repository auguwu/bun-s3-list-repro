import { S3Client } from "bun";

const client = new S3Client({
    region: "us-east-1",
    endpoint: "http://localhost:9000",
    accessKeyId: "somedummyaccesskey",
    secretAccessKey: "somedummysecretkey",
    bucket: "default",
});

console.log(await client.list());
