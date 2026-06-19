import MateriasRepository from '../repositories/materias-repository.js';

export default class MateriasService {
    constructor() {
        console.log('Estoy en: MateriasService.constructor()');
        this.MateriasRepository = new MateriasRepository();
    }

    getAllAsync = async () => {
        console.log(`MateriasService.getAllAsync()`);
        return await this.MateriasRepository.getAllAsync();
    }

    getByIdAsync = async (id) => {
        console.log(`MateriasService.getByIdAsync(${id})`);
        return await this.MateriasRepository.getByIdAsync(id);
    }

    createAsync = async (entity) => {
        console.log(`MateriasService.createAsync(${JSON.stringify(entity)})`);
        if (!entity || !entity.nombre || entity.nombre.toString().trim() === '') {
            throw new Error('El nombre de la materia es obligatorio.');
        }
        const newId = await this.MateriasRepository.createAsync(entity);
        return newId;
    }

    updateAsync = async (entity) => {
        console.log(`MateriasService.updateAsync(${JSON.stringify(entity)})`);
        const rowsAffected = await this.MateriasRepository.updateAsync(entity);
        return rowsAffected;
    }

    deleteByIdAsync = async (id) => {
        console.log(`MateriasService.deleteByIdAsync(${id})`);
        const rowsAffected = await this.MateriasRepository.deleteByIdAsync(id);
        return rowsAffected;
    }
}
