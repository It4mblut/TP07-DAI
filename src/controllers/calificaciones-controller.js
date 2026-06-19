import { Router } from 'express';
import { StatusCodes } from 'http-status-codes';
import CalificacionesService from './../services/calificaciones-service.js'

const router = Router();
const currentService = new CalificacionesService();

router.get('', async (req, res) => {
    try {
        const returnArray = await currentService.getAllAsync();
        if (returnArray != null){
            res.status(StatusCodes.OK).json(returnArray);
        } else {
            res.status(StatusCodes.INTERNAL_SERVER_ERROR).send(`Error interno.`);
        }
    } catch (error) {
        console.log(error);
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).send(`Error: ${error.message}`);
    }
});

router.get('/:id', async (req, res) => {
    try {
        let id = req.params.id;
        const returnEntity = await currentService.getByIdAsync(id);
        if (returnEntity != null){
            res.status(StatusCodes.OK).json(returnEntity);
        } else {
            res.status(StatusCodes.NOT_FOUND).send(`No se encontró la calificación (id: ${id}).`);
        }
    } catch (error) {
        console.log(error);
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).send(`Error: ${error.message}`);
    }
});

router.get('/alumno/:idAlumno', async (req, res) => {
    try {
        const idAlumno = req.params.idAlumno;
        const returnArray = await currentService.getByAlumnoAsync(idAlumno);
        res.status(StatusCodes.OK).json(returnArray);
    } catch (error) {
        console.log(error);
        // Si el service lanza un error por alumno inexistente devolvemos 404
        if (error.message && error.message.startsWith('El alumno')) {
            return res.status(StatusCodes.NOT_FOUND).send(error.message);
        }
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).send(`Error: ${error.message}`);
    }
});

router.post('', async (req, res) => {
    try {
        const entity = req.body;
        const newRow = await currentService.createAsync(entity);
        if (newRow != null){
            res.status(StatusCodes.CREATED).json(newRow);
        } else {
            res.status(StatusCodes.BAD_REQUEST).json(null);
        }
    } catch (error) {
        console.log(error);
        // Conflict por duplicado
        if (error.message && error.message.startsWith('Ya existe una calificación')) {
            return res.status(StatusCodes.CONFLICT).json({ error: error.message });
        }
        res.status(StatusCodes.BAD_REQUEST).json({ error: error.message });
    }
});

router.put('/:id', async (req, res) => {
    try {
        const id = parseInt(req.params.id);
        const entity = req.body || {};
        const rowsAffected = await currentService.updateAsync(id, entity);
        if (rowsAffected != 0){
            res.status(StatusCodes.OK).json(rowsAffected);
        } else {
            res.status(StatusCodes.NOT_FOUND).send(`No se encontró la calificación (id: ${id}).`);
        }
    } catch (error) {
        console.log(error);
        if (error.message && error.message.startsWith('No se encontró la calificación')) {
            return res.status(StatusCodes.NOT_FOUND).send(error.message);
        }
        res.status(StatusCodes.BAD_REQUEST).json({ error: error.message });
    }
});

router.delete('/:id', async (req, res) => {
    try {
        let id = req.params.id;
        const rowCount = await currentService.deleteByIdAsync(id);
        if (rowCount != 0){
            res.status(StatusCodes.OK).json(null);
        } else {
            res.status(StatusCodes.NOT_FOUND).send(`No se encontró la calificación (id: ${id}).`);
        }
    } catch (error) {
        console.log(error);
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).send(`Error: ${error.message}`);
    }
});

export default router;
