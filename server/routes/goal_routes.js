import { createNewGoal, deleteGoalById, deleteGoalHistory, getLatestGoal, getPureAdaptiveGoal, updateCurrentGoalsToInactive, updateGoalById } from '../controllers/goal_controller.js';
import { verifyToken } from '../middleware/auth_middleware.js'
import express from 'express'

const goalRouter = express.Router();

goalRouter.use(verifyToken); 

goalRouter.post('/goal', createNewGoal)
goalRouter.get('/goal', getLatestGoal)
goalRouter.patch('/goal/:id', updateGoalById)
goalRouter.delete('/goal/:id', deleteGoalById)
goalRouter.patch('/goal', updateCurrentGoalsToInactive)
goalRouter.delete('/goal', deleteGoalHistory);
goalRouter.get('/adaptive-goal', getPureAdaptiveGoal)

export default goalRouter