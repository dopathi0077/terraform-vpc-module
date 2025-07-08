resource "aws_vpc_peering_connection" "default" {
  count = var.is_peering_required ? 1 : 0
  vpc_id      = aws_vpc.main.id # requestor vpc id 
  peer_vpc_id = data.aws_vpc.default.id # acceptor vpc default  id 
  auto_accept = true

  tags = merge(
    var.vpc_perring_tags,
    local.common_tags,
    {
    Name = "${var.project}-${var.environment}-default"
    }
  )
}

resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id =  aws_vpc_peering_connection.default[count.index].id
}

resource "aws_route" "pivate_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id =  aws_vpc_peering_connection.default[count.index].id
}

resource "aws_route" "database_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id =  aws_vpc_peering_connection.default[count.index].id
}

# we need to add vpc peering connection  for default vpc main route table
resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.main.id # to get default vpc main route table
  destination_cidr_block    = var.cidr_block # cidr of main vpc 
  vpc_peering_connection_id =  aws_vpc_peering_connection.default[count.index].id
}