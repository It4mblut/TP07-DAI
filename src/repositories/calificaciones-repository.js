import pkg from 'pg'
import config from './../configs/db-config.js';
import LogHelper from './../helpers/log-helper.js'

const { Pool }  = pkg;

export default class CalificacionesRepository {
    constructor() {
        console.log('Estoy en: CalificacionesRepository.constructor()');
        this.DBPool = null;
    }

    getDBPool = () => {
        if (this.DBPool == null){
            this.DBPool = new Pool(config);
        }
        return this.DBPool;
    }

    // Trae todas las calificaciones con nombre de alumno y materia
    getAllAsync = async () => {
        console.log(`CalificacionesRepository.getAllAsync()`);
        let returnArray = null;
        try {
            const sql = `SELECT c.id, c.id_alumno, a.nombre AS nombre_alumno, a.apellido AS apellido_alumno,
                                 c.id_materia, m.nombre AS nombre_materia, c.nota, c.fecha
                          FROM calificaciones c
                          JOIN alumnos a ON c.id_alumno = a.id
                          JOIN materias m ON c.id_materia = m.id`;
            const resultPg = await this.getDBPool().query(sql);
            returnArray = resultPg.rows;
        } catch (error) {
            LogHelper.logError(error);
        }
        return returnArray;
    }

    getByIdAsync = async (id) => {
        console.log(`CalificacionesRepository.getByIdAsync(${id})`);
        let returnEntity = null;
        try {
            const sql = `SELECT c.id, c.id_alumno, a.nombre AS nombre_alumno, a.apellido AS apellido_alumno,
                                 c.id_materia, m.nombre AS nombre_materia, c.nota, c.fecha
                          FROM calificaciones c
                          JOIN alumnos a ON c.id_alumno = a.id
                          JOIN materias m ON c.id_materia = m.id
                          WHERE c.id = $1`;
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

    // Trae calificaciones de un alumno con nombre de materia
    getByAlumnoAsync = async (idAlumno) => {
        console.log(`CalificacionesRepository.getByAlumnoAsync(${idAlumno})`);
        let returnArray = null;
        try {
            const sql = `SELECT c.id, c.id_materia, m.nombre AS nombre_materia, c.nota, c.fecha
                         FROM calificaciones c
                         JOIN materias m ON c.id_materia = m.id
                         WHERE c.id_alumno = $1`;
            const values = [idAlumno];
            const resultPg = await this.getDBPool().query(sql, values);
            returnArray = resultPg.rows;
        } catch (error) {
            LogHelper.logError(error);
        }
        return returnArray;
    }

    // Comprueba si ya existe una calificacion para la combinacion alumno+materia
    existsByAlumnoMateria = async (idAlumno, idMateria) => {
        console.log(`CalificacionesRepository.existsByAlumnoMateria(${idAlumno},${idMateria})`);
        let exists = false;
        try {
            const sql = `SELECT 1 FROM calificaciones WHERE id_alumno = $1 AND id_materia = $2`;
            const values = [idAlumno, idMateria];
            const resultPg = await this.getDBPool().query(sql, values);
            exists = resultPg.rows.length > 0;
        } catch (error) {
            LogHelper.logError(error);
        }
        return exists;
    }

    createAsync = async (entity) => {
        console.log(`CalificacionesRepository.createAsync(${JSON.stringify(entity)})`);
        let newRow = null;
        try {
            const sql = `INSERT INTO calificaciones (id_alumno, id_materia, nota, fecha)
                         VALUES ($1, $2, $3, COALESCE($4, CURRENT_DATE)) RETURNING *`;
            const values = [entity.id_alumno, entity.id_materia, entity.nota, entity.fecha ?? null];
            const resultPg = await this.getDBPool().query(sql, values);
            newRow = resultPg.rows[0];
        } catch (error) {
            LogHelper.logError(error);
        }
        return newRow;
    }

    updateAsync = async (id, entity) => {
        console.log(`CalificacionesRepository.updateAsync(${id}, ${JSON.stringify(entity)})`);
        let rowsAffected = 0;
        try {
            const sql = `UPDATE calificaciones SET nota = COALESCE($2, nota), fecha = COALESCE($3, fecha) WHERE id = $1`;
            const values = [id, entity?.nota ?? null, entity?.fecha ?? null];
            const resultPg = await this.getDBPool().query(sql, values);
            rowsAffected = resultPg.rowCount;
        } catch (error) {
            LogHelper.logError(error);
        }
        return rowsAffected;
    }

    deleteByIdAsync = async (id) => {
        console.log(`CalificacionesRepository.deleteByIdAsync(${id})`);
        let rowsAffected = 0;
        try {
            const sql = `DELETE FROM calificaciones WHERE id=$1`;
            const values = [id];
            const resultPg = await this.getDBPool().query(sql, values);
            rowsAffected = resultPg.rowCount;
        } catch (error) {
            LogHelper.logError(error);
        }
        return rowsAffected;
    }
}
