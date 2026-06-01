import pkg from 'pg'
import config from './../configs/db-config.js';
import LogHelper from './../helpers/log-helper.js'

const { Pool } = pkg;

export default class DbPg {
    constructor() {
        this.DBPool = null;
    }

    getDBPool = () => {
        if (this.DBPool == null) {
            this.DBPool = new Pool(config);
        }
        return this.DBPool;
    }

    queryAll = async (sql, values = null) => {
        let returnArray = null;
        try {
            const resultPg = values
                ? await this.getDBPool().query(sql, values)
                : await this.getDBPool().query(sql);
            returnArray = resultPg.rows;
        } catch (error) {
            LogHelper.logError(error);
        }
        return returnArray;
    }

    queryOne = async (sql, values = null) => {
        let returnEntity = null;
        try {
            const resultPg = values
                ? await this.getDBPool().query(sql, values)
                : await this.getDBPool().query(sql);
            if (resultPg.rows.length > 0) {
                returnEntity = resultPg.rows[0];
            }
        } catch (error) {
            LogHelper.logError(error);
        }
        return returnEntity;
    }

    queryReturnId = async (sql, values = null) => {
        let newId = 0;
        try {
            const resultPg = values
                ? await this.getDBPool().query(sql, values)
                : await this.getDBPool().query(sql);
            newId = resultPg.rows[0].id;
        } catch (error) {
            LogHelper.logError(error);
        }
        return newId;
    }

    queryRowCount = async (sql, values = null) => {
        let rowsAffected = 0;
        try {
            const resultPg = values
                ? await this.getDBPool().query(sql, values)
                : await this.getDBPool().query(sql);
            rowsAffected = resultPg.rowCount;
        } catch (error) {
            LogHelper.logError(error);
        }
        return rowsAffected;
    }
}
