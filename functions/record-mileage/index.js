module.exports = function(context, req) {
  context.log("JavaScript HTTP trigger function processed a request.");

  // TODO: add an entry to the storage container? table?

  const name = req.query.name || (req.body && req.body.name);

  if (name) {
    context.res = {
      // status: 200, /* Defaults to 200 */
      body: "Hello " + (req.query.name || req.body.name)
    };
  } else {
    context.res = {
      status: 400,
      body: "Please pass a name on the query string or in the request body"
    };
  }
  context.done();
};
