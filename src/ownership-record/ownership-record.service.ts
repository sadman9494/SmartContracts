import { Injectable } from '@nestjs/common';
import { OwnershipRecordDto } from './dto/ownership-record.dto';
import { OwnershipRecordEntity } from './entities/ownership-record.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

@Injectable()
export class OwnershipRecordService {
  constructor(
    @InjectRepository(OwnershipRecordEntity)
    private readonly ownershipRepository: Repository<OwnershipRecordEntity>,
  ) {}
  create(ownershipRecordDto: OwnershipRecordDto) {
    return this.ownershipRepository.save(ownershipRecordDto);
  }

  findAll() {
    return this.ownershipRepository.find({ relations: ['Owner', 'Phone'] });
  }

  findOne(id: number) {
    return this.ownershipRepository.findOne({
      where: { OwnershipRecordId: id },
      relations: ['Owner', 'Phone'],
    });
  }

  findByPhone(id: number) {
    return this.ownershipRepository.find({
      where: {
        Phone: {
          PhoneId: id,
        },
      },
    });
  }

  findByOwner(id: number) {
    return this.ownershipRepository.find({
      where: {
        Owner: {
          OwnerId: id,
        },
      },
    });
  }

  update(id: number, ownershipRecordDto: OwnershipRecordDto) {
    return this.ownershipRepository.update(id, ownershipRecordDto);
  }

  remove(id: number) {
    return this.ownershipRepository.delete(id);
  }
}
