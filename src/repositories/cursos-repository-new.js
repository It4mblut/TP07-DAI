import Db from './db-pg.js';

export default class CursosRepository {
    constructor() {
        console.log('Estoy en: CursosRepository.constructor()');
        this.db = new Db();
    }

    getAllAsync = async () => {
        console.log(`CursosRepository.getAllAsync()`);
        const sql = `SELECT * FROM cursos`;
        return await this.db.queryAll(sql);
    }

    getByIdAsync = async (id) => {
        console.log(`CursosRepository.getByIdAsync(${id})`);
        const sql = `SELECT * FROM cursos WHERE id=$1`;
        return await this.db.queryOne(sql, [id]);
    }

    createAsync = async (entity) => {
        console.log(`CursosRepository.createAsync(${JSON.stringify(entity)})`);
        const sql = `INSERT INTO cursos (nombre) VALUES ($1) RETURNING id`;
        const values = [entity?.nombre ?? ''];
        return await this.db.queryReturnId(sql, values);
    }

    updateAsync = async (entity) => {
        console.log(`CursosRepository.updateAsync(${JSON.stringify(entity)})`);
        const sql = `UPDATE cursos SET nombre = $2 WHERE id = $1`;
        const values =  [   entity.id, 
                            entity?.nombre ?? ''
                        ];
        return await this.db.queryRowCount(sql, values);
    }

    deleteByIdAsync = async (id) => {
        console.log(`CursosRepository.deleteByIdAsync(${id})`);
        const sql = `DELETE FROM cursos WHERE id=$1`;
        return await this.db.queryRowCount(sql, [id]);
    }
}
