import { Router } from 'express';
import { StatusCodes } from 'http-status-codes';
import AlumnosService from './../services/alumnos-service.js'
import Alumno from './../entities/alumno.js'

const router = Router();
const currentService = new AlumnosService();

// Endpoint de ejemplo: crear un alumno desde código usando la clase Alumno
// En vez de recibir los datos del body (req.body), los armamos nosotros desde código.
// Para eso usamos la clase Alumno de la carpeta entities.
// Probar con: GET http://localhost:3000/api/alumnos/test-insert
router.get('/test-insert', async (req, res) => {
    console.log('/test-insert');
    try {
        const nuevoAlumno = new Alumno('Willy', 'Wonka', 1, '2005-07-15', true);

        console.log('Objeto Alumno creado desde código:', nuevoAlumno);

        const newId = await currentService.createAsync(nuevoAlumno);
        if (newId > 0) {
            res.status(StatusCodes.CREATED).json({
                message : `Se creó el alumno desde código con id: ${newId}`,
                alumno  : nuevoAlumno,
                newId   : newId
            });
        } else {
            res.status(StatusCodes.BAD_REQUEST).json({ message: 'No se pudo crear el alumno.' });
        }
    } catch (error) {
        console.log(error);
        res.status(StatusCodes.BAD_REQUEST).send(`Error: ${error.message}`);
    }
});

router.get('', async (req, res) => {
    try {
        console.log(`AlumnosController.get`);
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
            res.status(StatusCodes.NOT_FOUND).send(`No se encontro la entidad (id:${id}).`);
        }
    } catch (error) {
        console.log(error);
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).send(`Error: ${error.message}`);
    }
});

router.post('', async (req, res) => {
    try {
        let entity = req.body;
        const newId = await currentService.createAsync(entity);
        if (newId > 0 ){
            res.status(StatusCodes.CREATED).json(newId);
        } else {
            res.status(StatusCodes.BAD_REQUEST).json(null);
        }
    } catch (error) {
        console.log(error);
        res.status(StatusCodes.BAD_REQUEST).send(`Error: ${error.message}`);
    }
});

router.put('/:id', async (req, res) => {
    try {
        let id = parseInt(req.params.id);
        let entity = req.body;

        if (entity.id && parseInt(entity.id) !== id) {
            return res.status(StatusCodes.BAD_REQUEST).send(`El id de la URL (${id}) no coincide con el id del body (${entity.id}).`);
        }

        entity.id = id;
        const rowsAffected = await currentService.updateAsync(entity);
        if (rowsAffected != 0){
            res.status(StatusCodes.OK).json(rowsAffected);
        } else {
            res.status(StatusCodes.NOT_FOUND).send(`No se encontro la entidad (id:${id}).`);
        }
    } catch (error) {
        console.log(error);
        res.status(StatusCodes.BAD_REQUEST).send(`Error: ${error.message}`);
    }
});

router.delete('/:id', async (req, res) => {
    try {
        let id = req.params.id;
        const rowCount = await currentService.deleteByIdAsync(id);
        if (rowCount != 0){
            res.status(StatusCodes.OK).json(null);
        } else {
            res.status(StatusCodes.NOT_FOUND).send(`No se encontro la entidad (id:${id}).`);
        }
    } catch (error) {
        console.log(error);
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).send(`Error: ${error.message}`);
    }
});



export default router;
