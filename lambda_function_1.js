exports.handler = async (event) => {
  // Your Lambda function code here
  return {
    statusCode: 200,
    body: JSON.stringify('Hello from Lambda Function-1'),
  };
};
