import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { OwnershipRecordService } from './ownership-record.service';
import { OwnershipRecordDto } from './dto/ownership-record.dto';

@Controller('OwnershipRecord')
export class OwnershipRecordController {
  constructor(
    private readonly ownershipRecordService: OwnershipRecordService,
  ) {}

  @Post()
  create(@Body() ownershipRecordDto: OwnershipRecordDto) {
    console.log(ownershipRecordDto);
    return this.ownershipRecordService.create(ownershipRecordDto);
  }

  @Get()
  findAll() {
    return this.ownershipRecordService.findAll();
  }

  @Get('Phone/:id')
  findByPhone(@Param('id') id: string) {
    return this.ownershipRecordService.findByPhone(+id);
  }

  @Get('Owner/:id')
  findByOwner(@Param('id') id: string) {
    return this.ownershipRecordService.findByOwner(+id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.ownershipRecordService.findOne(+id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() ownershipRecordDto: OwnershipRecordDto,
  ) {
    console.log(ownershipRecordDto);
    return this.ownershipRecordService.update(+id, ownershipRecordDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.ownershipRecordService.remove(+id);
  }
}
