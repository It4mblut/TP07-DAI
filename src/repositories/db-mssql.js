import sql from 'mssql'
import config from './../configs/db-config.js';
import LogHelper from './../helpers/log-helper.js'

export default class DbMssql {
    constructor() {
        this.pool = null;
    }

    getPool = async () => {
        if (this.pool == null) {
            this.pool = await sql.connect(config);
        }
        return this.pool;
    }

    queryAll = async (sqlQuery, values = null) => {
        let returnArray = null;
        try {
            const pool = await this.getPool();
            const request = pool.request();
            this.addParams(request, values);
            const result = await request.query(sqlQuery);
            returnArray = result.recordset;
        } catch (error) {
            LogHelper.logError(error);
        }
        return returnArray;
    }

    queryOne = async (sqlQuery, values = null) => {
        let returnEntity = null;
        try {
            const pool = await this.getPool();
            const request = pool.request();
            this.addParams(request, values);
            const result = await request.query(sqlQuery);
            if (result.recordset.length > 0) {
                returnEntity = result.recordset[0];
            }
        } catch (error) {
            LogHelper.logError(error);
        }
        return returnEntity;
    }

    queryReturnId = async (sqlQuery, values = null) => {
        let newId = 0;
        try {
            const pool = await this.getPool();
            const request = pool.request();
            this.addParams(request, values);
            const result = await request.query(sqlQuery);
            newId = result.recordset[0].id;
        } catch (error) {
            LogHelper.logError(error);
        }
        return newId;
    }

    queryRowCount = async (sqlQuery, values = null) => {
        let rowsAffected = 0;
        try {
            const pool = await this.getPool();
            const request = pool.request();
            this.addParams(request, values);
            const result = await request.query(sqlQuery);
            rowsAffected = result.rowsAffected[0];
        } catch (error) {
            LogHelper.logError(error);
        }
        return rowsAffected;
    }

    // mssql usa @param1, @param2... en vez de $1, $2...
    // Este helper agrega los valores al request con nombres param1, param2, etc.
    addParams = (request, values) => {
        if (values == null) return;
        values.forEach((value, index) => {
            request.input(`param${index + 1}`, value);
        });
    }
}
