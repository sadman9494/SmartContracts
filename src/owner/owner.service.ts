import { Injectable } from '@nestjs/common';
import { OwnerDto } from './dto/owner.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { OwnerEntity } from './entities/owner.entity';

@Injectable()
export class OwnerService {
  constructor(
    @InjectRepository(OwnerEntity)
    private readonly ownerRepository: Repository<OwnerEntity>,
  ) {}

  create(ownerDto: OwnerDto) {
    return this.ownerRepository.save(ownerDto);
  }

  findAll() {
    return this.ownerRepository.find({ relations: ['OwnershipRecords'] });
  }

  findOne(id: any) {
    return this.ownerRepository.findOne({
      where: { OwnerId: id },
      relations: ['OwnershipRecords'],
    });
  }

  update(id: any, ownerDto: OwnerDto) {
    // const {OwnerId, ...updateOwnerDto} = ownerDto;
    // return this.ownerRepository.update(id, ownerDto);
    return this.ownerRepository.update(id, ownerDto);
  }

  remove(id: number) {
    return this.ownerRepository.delete(id);
  }
}
