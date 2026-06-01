import pkg from 'pg'
import config from './../configs/db-config.js';      // Traigo la configuracion de la base de datos.
import LogHelper from './../helpers/log-helper.js'

const { Pool }  = pkg;

export default class CursosRepository {
    constructor() {
        // Se ejecuta siempre, (al instanciar la clase)
        console.log('Estoy en: CursosRepository.constructor()');
        this.DBPool     = null;
    }

    getDBPool = () => {
        if (this.DBPool == null){
            this.DBPool = new Pool(config);
        }
        return this.DBPool;
    }

    getAllAsync = async () => {
        console.log(`CursosRepository.getAllAsync()`);
        let returnArray = null;
        
        try {
            const sql = `SELECT * FROM cursos`;
            const resultPg = await this.getDBPool().query(sql);
            returnArray = resultPg.rows;
        } catch (error) {
            LogHelper.logError(error);
        }
        return returnArray;
    }

    getByIdAsync = async (id) => {
        console.log(`CursosRepository.getByIdAsync(${id})`);
        let returnEntity = null;
        try {
            const sql = `SELECT * FROM cursos WHERE id=$1`;
            const values = [id];
            const resultPg = await this.getDBPool().query(sql, values);
            if (resultPg.rows.length > 0){
                returnEntity = resultPg.rows[0];
            }
        } catch (error) {
            LogHelper.logError(error);
        }
        return returnEntity;
    }

    createAsync = async (entity) => {
        console.log(`CursosRepository.createAsync(${JSON.stringify(entity)})`);
        let newId = 0;

        try {
            const sql = `INSERT INTO cursos (nombre) VALUES ($1) RETURNING id`;
            const values = [entity?.nombre ?? ''];
            const resultPg = await this.getDBPool().query(sql, values);
            newId = resultPg.rows[0].id;
        } catch (error) {
            LogHelper.logError(error);
        }
        return newId;
    }

    updateAsync = async (entity) => {
        console.log(`CursosRepository.updateAsync(${JSON.stringify(entity)})`);
        let rowsAffected = 0;
        let id = entity.id;

        try {
            const sql = `UPDATE cursos SET nombre = $2 WHERE id = $1`;
            const values = [id, entity?.nombre ?? ''];
            const resultPg = await this.getDBPool().query(sql, values);
            rowsAffected = resultPg.rowCount;
        } catch (error) {
            LogHelper.logError(error);
        }
        return rowsAffected;
    }

    deleteByIdAsync = async (id) => {
        console.log(`CursosRepository.deleteByIdAsync(${id})`);
        let rowsAffected = 0;

        try {
            const sql = `DELETE FROM cursos WHERE id=$1`;
            const values = [id];
            const resultPg = await this.getDBPool().query(sql, values);
            rowsAffected = resultPg.rowCount;
        } catch (error) {
            LogHelper.logError(error);
        }
        return rowsAffected;
    }
}
