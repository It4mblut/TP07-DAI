import CalificacionesRepository from '../repositories/calificaciones-repository.js';
import AlumnosService from './alumnos-service.js';
import MateriasService from './materias-service.js';

function validarNota(nota) {
    if (nota === undefined || nota === null) return false;
    if (!Number.isInteger(nota)) return false;
    if (nota < 0 || nota > 10) return false;
    return true;
}

export default class CalificacionesService {
    constructor() {
        console.log('Estoy en: CalificacionesService.constructor()');
        this.CalificacionesRepository = new CalificacionesRepository();
        this.AlumnosService = new AlumnosService();
        this.MateriasService = new MateriasService();
    }

    getAllAsync = async () => {
        console.log('CalificacionesService.getAllAsync()');
        return await this.CalificacionesRepository.getAllAsync();
    }

    getByIdAsync = async (id) => {
        console.log(`CalificacionesService.getByIdAsync(${id})`);
        const entity = await this.CalificacionesRepository.getByIdAsync(id);
        return entity;
    }

    getByAlumnoAsync = async (idAlumno) => {
        console.log(`CalificacionesService.getByAlumnoAsync(${idAlumno})`);
        // Validar que el alumno exista
        const alumno = await this.AlumnosService.getByIdAsync(idAlumno);
        if (alumno == null) {
            throw new Error(`El alumno con id ${idAlumno} no existe.`);
        }
        const returnArray = await this.CalificacionesRepository.getByAlumnoAsync(idAlumno);
        return returnArray;
    }

    createAsync = async (entity) => {
        console.log(`CalificacionesService.createAsync(${JSON.stringify(entity)})`);
        // 1) validar nota
        if (!validarNota(entity?.nota)) {
            throw new Error('La nota debe ser un número entero entre 0 y 10.');
        }

        // 2) validar alumno existe
        if (!entity?.id_alumno) {
            throw new Error(`El alumno con id ${entity?.id_alumno} no existe.`);
        }
        const alumno = await this.AlumnosService.getByIdAsync(entity.id_alumno);
        if (alumno == null) {
            throw new Error(`El alumno con id ${entity.id_alumno} no existe.`);
        }

        // 3) validar materia existe
        if (!entity?.id_materia) {
            throw new Error(`La materia con id ${entity?.id_materia} no existe.`);
        }
        const materia = await this.MateriasService.getByIdAsync(entity.id_materia);
        if (materia == null) {
            throw new Error(`La materia con id ${entity.id_materia} no existe.`);
        }

        // 4) validar duplicado
        const exists = await this.CalificacionesRepository.existsByAlumnoMateria(entity.id_alumno, entity.id_materia);
        if (exists) {
            throw new Error(`Ya existe una calificación para el alumno ${entity.id_alumno} en la materia ${entity.id_materia}.`);
        }

        // Crear
        const newRow = await this.CalificacionesRepository.createAsync(entity);
        return newRow;
    }

    updateAsync = async (id, entity) => {
        console.log(`CalificacionesService.updateAsync(${id}, ${JSON.stringify(entity)})`);
        // 1) debe existir la calificacion
        const existing = await this.CalificacionesRepository.getByIdAsync(id);
        if (existing == null) {
            throw new Error(`No se encontró la calificación (id: ${id}).`);
        }

        // 2) si se envia nota, validar rango
        if (entity.hasOwnProperty('nota')) {
            if (!validarNota(entity.nota)) {
                throw new Error('La nota debe ser un número entero entre 0 y 10.');
            }
        }

        const rowsAffected = await this.CalificacionesRepository.updateAsync(id, entity);
        return rowsAffected;
    }

    deleteByIdAsync = async (id) => {
        console.log(`CalificacionesService.deleteByIdAsync(${id})`);
        const rowsAffected = await this.CalificacionesRepository.deleteByIdAsync(id);
        return rowsAffected;
    }
}
