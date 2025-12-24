import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { PhoneDto } from 'src/phone/dto/phone.dto';
import { PhoneEntity } from './entities/phone.entity';
import { Repository } from 'typeorm';

@Injectable()
export class PhoneService {
  constructor(
    @InjectRepository(PhoneEntity)
    private readonly phoneRepository: Repository<PhoneEntity>,
  ) {}

  create(phoneDto: PhoneDto) {
    console.log(phoneDto);
    return this.phoneRepository.save(phoneDto);
  }

  findAll() {
    return this.phoneRepository.find({ relations: ['OwnershipRecords'] });
  }

  findOne(id: any) {
    return this.phoneRepository.findOne({
      where: { PhoneId: id },
      relations: ['OwnershipRecords'],
    });
  }

  update(id: any, phoneDto: PhoneDto) {
    // const {PhoneId, ...updatePhoneDto} = phoneDto;
    // return this.phoneRepository.update(id, phoneDto);
    return this.phoneRepository.update(id, phoneDto);
  }

  remove(id: number) {
    return this.phoneRepository.delete(id);
  }
}
