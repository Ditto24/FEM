% ������ϲ���
E = 200e9; % ����ģ����Pa��
nu = 0.3; % ���ɱ�

% �����������
q = 10e6; % ����������N/m��

% ���屡��ߴ�
Lx = 1; % ���峤�ȣ�m��
Ly = 1; % �����ȣ�m��

% ���㵥Ԫ�ߴ���ܵ�Ԫ����
dx = Lx / 20; % ��Ԫ���ȣ�m��
dy = Ly / 20; % ��Ԫ��ȣ�m��
Nx = Lx / dx; % ����Ԫ����
Ny = Ly / dy; % ����Ԫ����
N = Nx * Ny; % �ܵ�Ԫ����

% ����ڵ�����
x = zeros(Nx+1, Ny+1);
y = zeros(Nx+1, Ny+1);
for i = 1:Nx+1
  for j = 1:Ny+1
    x(i,j) = (i-1) * dx;
    y(i,j) = (j-1) * dy;
  end
end

% ������Ԫ�ͽڵ�Ĺ�����ϵ
IEN = zeros(N, 3);
for i = 1:Nx
  for j = 1:Ny
    n = (j-1)*Nx + i;
    IEN(n, :) = [n, n+1, n+Nx+1];
  end
end

% ��ʼ���ܸնȾ�����غ�����
K = zeros((Nx+1)*(Ny+1), (Nx+1)*(Ny+1));
F = zeros((Nx+1)*(Ny+1), 1);

% ѭ������ÿ����Ԫ�����㵥Ԫ������͸նȾ��󣬲�������װ���ܸնȾ�����
for e = 1:N
  nodes = IEN(e, :);
  x1 = x(nodes(1));
  x2 = x(nodes(2));
  x3 = x(nodes(3));
  y1 = y(nodes(1));
  y2 = y(nodes(2));
  y3 = y(nodes(3));

  % ���㵥Ԫ���
  A = (x1*(y2-y3) + x2*(y3-y1) + x3*(y1-y2)) / 2;

  % ���㵥Ԫ�նȾ���
  Ke = (E/(1-nu^2)) * (1/(4*A)) * [...
    (y2-y3)^2+(x2-x3)^2, (x2-x3)*(y2-y3), (y2-y3)*(x2-x1);...
    (x2-x3)*(y2-y3), (x2-x3)^2+(y2-y3)^2, (x2-x3)*(y3-y1);...
    (y2-y3)*(x2-x1), (x2-x3)*(y3-y1), (y3-y1)^2+(x2-x1)^2];

  % ����Ԫ�նȾ�����װ���ܸնȾ�����
  K(nodes, nodes) = K(nodes, nodes) + Ke;
end

% ����߽�����
fixed_nodes = [1, Nx+1, (Nx+1)*(Ny+1)-1, (Nx+1)*(Ny+1)];
K(fixed_nodes, :) = 0;
K(:, fixed_nodes) = 0;
F(fixed_nodes) = 0;

% ���λ�ƾ���
U = K \ F;

% ����ÿ����Ԫ��Ӧ��
sigma = zeros(N, 3);
for e = 1:N
  nodes = IEN(e, :);
  x1 = x(nodes(1));
  x2 = x(nodes(2));
  x3 = x(nodes(3));
  y1 = y(nodes(1));
  y2 = y(nodes(2));
  y3 = y(nodes(3));

  % ���㵥Ԫλ��
  u1 = U(nodes(1));
  u2 = U(nodes(2));
  u3 = U(nodes(3));

  % ���㵥ԪӦ��
  B = (1 / (2 * A)) * [...
    (y2-y3), 0, (y3-y1);...
    0, (x3-x2), 0;...
    (y3-y1), 0, (y1-y2)];
  sigma(e, :) = (E / (1 - nu^2)) * B * U(nodes);
end

% ����Ӧ��
figure;
for e = 1:N
  nodes = IEN(e, :);
  nodes = nodes(:);

  % ���㵥Ԫλ��
  u1 = U(nodes(1));
  u2 = U(nodes(2));
  u3 = U(nodes(3));

  % ���㵥ԪӦ��
  sigma = (E / (1 - nu^2)) * B * U(nodes);

  % ����Ӧ��
  plot([x1, x2, x3], [y1, y2, y3], 'Color', [0.8, 0.8, 0.8], 'LineWidth', 1);
  text(x1, y1, sprintf('��_x = %.2f', sigma(e, 1)), 'HorizontalAlignment', 'left');
  text(x2, y2, sprintf('��_y = %.2f', sigma(e, 2)), 'VerticalAlignment', 'bottom');
  text(x3, y3, sprintf('��_z = %.2f', sigma(e, 3)), 'HorizontalAlignment', 'right');
end
