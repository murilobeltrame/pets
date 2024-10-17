import { NotFoundError } from "../models/exceptions";
import Pet from "../models/pet";

const notFound = new NotFoundError("Pet not found");

export class PetsService {
  async fetchPets(): Promise<Pet[]> {
    return await Pet.findAll();
  }

  async getPet(id: number): Promise<Pet | undefined> {
    const pet = await Pet.findByPk(id);
    if (pet === null) throw notFound;
    return pet;
  }

  async createPet(pet: Pet): Promise<Pet> {
    const createdPet = await Pet.create({ ...pet });
    return createdPet;
  }

  async updatePet(id: number, pet: Pet): Promise<void> {
    const dontExists = (await Pet.findByPk(id)) === null;
    if (dontExists) throw notFound;
    await Pet.update({ ...pet }, { where: { id } });
  }

  async deletePet(id: number): Promise<void> {
    const dontExists = (await Pet.findByPk(id)) === null;
    if (dontExists) throw notFound;
    await Pet.destroy({ where: { id } });
  }
}
