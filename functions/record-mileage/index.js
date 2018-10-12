const azure = require('azure-storage');

const connectionString = [
  'DefaultEndpointsProtocol=http',
  'AccountName=devstoreaccount1',
  'AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==',
  'BlobEndpoint=http://storage:10000/devstoreaccount1',
  'QueueEndpoint=http://storage:10001/devstoreaccount1',
  'TableEndpoint=http://storage:10002/devstoreaccount1',
].join(';');

const containerName = 'mileage';
const driversTableName = 'driversTable';
const mileageTableName = 'mileageTable';

const blobService = azure.createBlobService(connectionString);
const tableService = azure.createTableService(connectionString);

module.exports = async function(context, req) {
  context.log('JavaScript HTTP trigger function processed a request.');

  // date
  const vehicleId = String(req.query.vehicleId || '');
  const dateString = String(req.query.date || '');
  const entryDate = new Date(dateString);
  const miles = Number(req.query.miles);
  const gallons = Number(req.query.gallons);
  const comments = String(req.body.comments || '');

  if (
    !vehicleId ||
    !dateString ||
    entryDate.toString() === 'Invalid Date' ||
    !(miles > 0) ||
    !(gallons > 0)
  ) {
    context.res = { status: 400 };
    context.done();
    return;
  }

  try {
    // TODO: add an entry to the storage container? table?

    /** @type {azure.services.table.TableService.TableResult} */
    const tableResult = await new Promise((resolve, reject) => {
      tableService.createTableIfNotExists(
        mileageTableName,
        (err, table) => (err ? reject(err) : resolve(table))
      );
    });

    const entGen = azure.TableUtilities.entityGenerator;
    const entry = {
      PartitionKey: entGen.Guid(vehicleId),
      RowKey: entGen.DateTime(entryDate),
      miles: entGen.Double(miles),
      gallons: entGen.Double(gallons),
      comments: entGen.String(comments),
    };

    /** @type {azure.services.table.TableService.EntityMetadata} */
    const result = await new Promise((resolve, reject) => {
      tableService.insertEntity(
        mileageTableName,
        entry,
        (err, meta) => (err ? reject(err) : resolve(meta))
      );
    });

    context.res = { status: 200 };
  } catch (err) {
    context.res = { status: 500, body: err };
  }

  context.done();
};
