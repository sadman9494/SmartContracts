import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { PhoneService } from './phone.service';
import { PhoneDto } from './dto/phone.dto';

@Controller('phone')
export class PhoneController {
  constructor(private readonly phoneService: PhoneService) {}

  @Post()
  create(@Body() phoneDto: PhoneDto) {
    return this.phoneService.create(phoneDto);
  }

  @Get()
  findAll() {
    return this.phoneService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.phoneService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() phoneDto: PhoneDto) {
    return this.phoneService.update(+id, phoneDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.phoneService.remove(+id);
  }
}
