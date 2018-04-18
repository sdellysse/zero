(async () => {
  const bunyan = require("bunyan");
  const Koa = require("koa");
  const koaBunyan = require("koa-bunyan");
  const KoaRouter = require("koa-router");
  const Pool = require("pg").Pool;

  const logger = bunyan.createLogger({
    name: "zero",
  });

  const db = new Pool({
    user: "postgres",
    database: "zero",
  });
  const withClient = async (cb) => {
    const client = await db.connect();

    try {
      const result = await cb(client);
      client.release();
      return result;
    } catch (e) {
      client.release();
      throw e;
    }
  };


  const koa = new Koa();
  const koaRouter = new KoaRouter();

  koa.use(koaBunyan(logger, {
  }));

  koaRouter.get("/account_types", async(ctx) => withClient(async (c) => {
    const res = await c.query(`
      SELECT account_type
      FROM account_types
    `);
    const rows = res.rows.map(({ account_type }) => account_type);

    ctx.body = {
      account_types: rows,
    };
  }));

  koaRouter.get("/accounts", async (ctx) => withClient(async (c) => {
    const res = await c.query(`
      WITH balances AS (
        SELECT account_name, SUM(amount) AS balance
        FROM transactions
        GROUP BY 1
      )

      SELECT
        aa.account_name,
        aa.account_type,
        aa.initial_balance,
        COALESCE(bb.balance, 0) AS balance
      FROM       accounts aa
      LEFT JOIN  balances bb USING (account_name)
    `);
    const rows = res.rows;

    ctx.body = {
      accounts: rows,
    };
  }));

  koaRouter.get("/accounts/:account_name", async (ctx) => withClient(async (c) => {
    const aRes = await c.query(`
      WITH balances AS (
        SELECT account_name, SUM(amount) AS balance
        FROM transactions
        WHERE account_name = $1
        GROUP BY 1
      )

      SELECT
        aa.account_name,
        aa.account_type,
        aa.initial_balance,
        COALESCE(bb.balance, 0) AS balance
      FROM       accounts aa
      LEFT JOIN  balances bb USING (account_name)
      WHERE aa.account_name = $1
    `, [ ctx.params.account_name ]);
    const a = aRes.rows[0];

    const tRes = await c.query(`
      SELECT
        transaction_id,
        at,
        account_name,
        subject_name,
        amount,
        memo
      FROM transactions
      WHERE account_name = $1
      ORDER BY at
    `, [ ctx.params.account_name ]);
    const tRows = tRes.rows;

    ctx.body = {
      ...a,
      transactions: tRows,
    };
  }));

  koa.use(koaRouter.routes());
  koa.use(koaRouter.allowedMethods());

  koa.listen(3000);
})();
